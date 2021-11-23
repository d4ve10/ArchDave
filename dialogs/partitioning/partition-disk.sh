#!/bin/bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
CURRENT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "${CURRENT_DIR}/select-disk.sh"

displayWarning() {
  whiptail --title "$1" --yesno "Selected device: "$2"\n\nALL DATA WILL BE ERASED!\n\nContinue?" --defaultno 0 0 3>&1 1>&2 2>&3
  return "$?"
}

partitionDiskMenu() {
  options=()
  if [[ ! -d "/sys/firmware/efi" ]]; then
    options+=("Auto Partitions (gpt)" "")
  else
    options+=("Auto Partitions (gpt,efi)" "")
  fi
  options+=("Edit Partitions (cfdisk)" "")
  options+=("Edit Partitions (cgdisk)" "")

  partitionOption=$(whiptail --backtitle "$TITLE" --title "Disk Partitions" --cancel-button "Back" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  selectDiskMenu
  if [ ! "$?" = "0" ]; then
    return 0
  fi
  case ${partitionOption} in
    "Auto Partitions (gpt)")
      if (displayWarning "Auto Partitions (gpt)" "$DISK"); then
        sgdisk -Z ${DISK} # zap all on disk
        sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

        # create partitions
        sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' ${DISK} # partition 1 (BIOS Boot Partition)
        sgdisk -n 2::+200M --typecode=2:ef00 --change-name=2:'BOOT' ${DISK} # partition 2 (Boot Partition)
        sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' ${DISK} # partition 3 (Root), default start, remaining
        sgdisk -A 1:set:2 ${DISK}
        BOOT_PARTITION_NUM=2
        ROOT_PARTITION_NUM=3
      fi
    ;;
    "Auto Partitions (gpt,efi)")
      if (displayWarning "Auto Partitions (gpt,efi)" "$DISK"); then
        sgdisk -Z ${DISK} # zap all on disk
        sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment

        # create partitions
        sgdisk -n 1::+200M --typecode=2:ef00 --change-name=1:'BOOT' ${DISK} # partition 1 (Boot Partition)
        sgdisk -n 2::-0 --typecode=3:8300 --change-name=2:'ROOT' ${DISK} # partition 2 (Root), default start, remaining
        BOOT_PARTITION_NUM=1
        ROOT_PARTITION_NUM=2
      fi
    ;;
    "Edit Partitions (cfdisk)")
      cfdisk ${DISK}
      menu selectPartitionMenu "$DISK"
      return "$?"
    ;;
    "Edit Partitions (cgdisk)")
      cgdisk ${DISK}
      menu selectPartitionMenu "$DISK"
      return "$?"
    ;;
  esac

  if [[ ! -z "$BOOT_PARTITION_NUM" ]] && [[ ! -z "$ROOT_PARTITION_NUM" ]]; then
    if [[ ${DISK} =~ "nvme" ]]; then
      export BOOT_PARTITION="${DISK}p${BOOT_PARTITION_NUM}"
      export ROOT_PARTITION="${DISK}p${ROOT_PARTITION_NUM}"
    else
      export BOOT_PARTITION="${DISK}${BOOT_PARTITION_NUM}"
      export ROOT_PARTITION="${DISK}${ROOT_PARTITION_NUM}"
    fi
    return 1
  fi
}