#!/usr/bin/env bash
#--------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
#  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  
#  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
#--------------------------------------------------------------------

iso=$(curl -4 ifconfig.co/country-iso)
sudo pacman -S --noconfirm --needed pacman-contrib curl
sudo pacman -S --noconfirm --needed reflector rsync
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
echo -e "--------------------------------------------------------------------"
echo -e "   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗"
echo -e "  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════╝"
echo -e "  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  "
echo -e "  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝  "
echo -e "  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗"
echo -e "  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝"
echo -e "--------------------------------------------------------------------"
echo -e "            Setting up $iso mirrors for faster downloads            "
echo -e "--------------------------------------------------------------------"
sudo reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist