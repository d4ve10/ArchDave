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

setHostnameMenu() {
  hostname=$(whiptail --backtitle "${TITLE}" --title "Set Computer Name" --inputbox "" 0 0 "archlinux" 3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  if [[ ! "$hostname" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]{1,62}$ || "${hostname: -1}" == "-" ]]; then
    whiptail --backtitle "${TITLE}" --title "Set Computer Name" --msgbox "Invalid Hostname\nOnly letters, numbers, underscore and hyphen are allowed, minimal of two characters" 0 0
    setHostnameMenu
    return "$?"
  fi
  if [ "$hostname" = "localhost" ]; then
    whiptail --backtitle "${TITLE}" --title "Set Computer Name" --msgbox "localhost is not allowed as hostname" 0 0
    setHostnameMenu
    return "$?"
  fi
  echo "HOSTNAME=$hostname" >> "${CURRENT_DIR}/../../install.conf"
}