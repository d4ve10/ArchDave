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
TITLE="$(basename $( cd -- "${CURRENT_DIR}/../" &> /dev/null && pwd ) )"

source "${CURRENT_DIR}/menu.sh"

mainmenu() {
	options=()
	options+=("Disk Partitions" "")
	options+=("Select Partitions and Install" "")
	sel=$(whiptail --backtitle "$TITLE" --title "Main Menu" --menu "" --cancel-button "Exit" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
	if [ ! "$?" = "0" ]; then
		return 1
	fi
	case ${sel} in
		"Disk Partitions")
			menu partitionDiskMenu
			exitcode="$?"
		;;
		"Select Partitions and Install")
			menu selectPartitionMenu
			exitcode="$?"
		;;
	esac
	if [ "$exitcode" = "2" ]; then
		return 1
	fi
}

menu mainmenu