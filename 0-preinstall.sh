#!/usr/bin/env bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

hwclock --systohc
timedatectl set-ntp true
pacman -S --noconfirm --needed terminus-font
setfont ter-v22b
source "$SCRIPT_DIR/functions/pacman.sh"
source "$SCRIPT_DIR/functions/mirrors.sh"
mkdir /mnt


echo -e "\nInstalling prereqs...\n$HR"
pacman -S --noconfirm --needed gptfdisk btrfs-progs grub

umount -R /mnt &>/dev/null

source "$SCRIPT_DIR/functions/partitioning/select-disk.sh"

echo "--------------------------------------"
echo -e "\nFormatting disk...\n$HR"
echo "--------------------------------------"
source "$SCRIPT_DIR/functions/partitioning/partition-disk.sh"

# make filesystems
echo -e "\nCreating Filesystems...\n$HR"

mkfs.vfat -F32 -n "BOOT" "$BOOT_PARTITION"
mkfs.btrfs -L "ROOT" "$ROOT_PARTITION" -f
mount -t btrfs "$ROOT_PARTITION" /mnt

ls /mnt | xargs btrfs subvolume delete
btrfs subvolume create /mnt/@
umount /mnt
;;
*)
echo "Rebooting in 3 Seconds ..." && sleep 1
echo "Rebooting in 2 Seconds ..." && sleep 1
echo "Rebooting in 1 Second ..." && sleep 1
reboot now
;;
esac

# mount target
mount -t btrfs -o subvol=@ -L ROOT /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount -t vfat -L BOOT /mnt/boot/

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted can not continue"
    echo "Rebooting in 3 Seconds ..." && sleep 1
    echo "Rebooting in 2 Seconds ..." && sleep 1
    echo "Rebooting in 1 Second ..." && sleep 1
    reboot now
fi

echo "--------------------------------------"
echo "-- Arch Install on Main Drive       --"
echo "--------------------------------------"
pacstrap /mnt base base-devel linux linux-firmware vim nano sudo archlinux-keyring wget libnewt --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
echo "DISK=$DISK" >> "$SCRIPT_DIR/install.conf"
cp -R ${SCRIPT_DIR} /mnt/root
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
echo "--------------------------------------"
echo "-- Check for low memory systems <8G --"
echo "--------------------------------------"
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -lt 8000000 ]]; then
    #Put swap into the actual system, not into RAM disk, otherwise there is no point in it, it'll cache RAM into RAM. So, /mnt/ everything.
    mkdir /mnt/opt/swap #make a dir that we can apply NOCOW to to make it btrfs-friendly.
    chattr +C /mnt/opt/swap #apply NOCOW, btrfs needs that.
    dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
    chmod 600 /mnt/opt/swap/swapfile #set permissions.
    chown root /mnt/opt/swap/swapfile
    mkswap /mnt/opt/swap/swapfile
    swapon /mnt/opt/swap/swapfile
    #The line below is written to /mnt/ but doesn't contain /mnt/, since it's just / for the sysytem itself.
    echo "/opt/swap/swapfile	none	swap	sw	0	0" >> /mnt/etc/fstab #Add swap to fstab, so it KEEPS working after installation.
fi
echo "--------------------------------------"
echo "--   SYSTEM READY FOR 1-setup       --"
echo "--------------------------------------"
