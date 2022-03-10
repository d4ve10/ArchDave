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
BASENAME="$( basename $SCRIPT_DIR)"

source $SCRIPT_DIR/install.conf

echo -ne "
--------------------------------------------------------------------
                    GRUB Bootloader Installation
--------------------------------------------------------------------
"
errors=0
installGrub() {
  if [[ ! -d "/sys/firmware/efi" ]]; then
      grub-install --boot-directory=/boot ${DISK}
  else
      grub-install --efi-directory=/boot ${DISK}
  fi
}
until installGrub
do
  if [[ $errors -ge 3 ]]; then
    echo "Grub installation failed"
    exit 1
  fi
  echo "Grub installation failed, retrying..."
  sleep 3
  errors=$((errors+1))
done

$SCRIPT_DIR/functions/grub.sh

echo -ne "
--------------------------------------------------------------------
                   Enabling Login Display Manager
--------------------------------------------------------------------
"
if [ "$DESKTOP_ENV" = "kde" ]; then
  systemctl enable sddm.service
  echo -e "[Theme]\nCurrent=breeze" > /etc/sddm.conf
  echo "/home/$USERNAME/bin/xrandr_display" >> /usr/share/sddm/scripts/Xsetup
elif [ "$DESKTOP_ENV" = "gnome" ]; then
  systemctl enable gdm.service
elif [ "$DESKTOP_ENV" = "lxde" ]; then
  systemctl enable lxdm.service
elif [ ! "$DESKTOP_ENV" = "none" ]; then
  pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter
  systemctl enable lightdm.service
fi

echo -ne "
--------------------------------------------------------------------
                     Enabling Essential Services
--------------------------------------------------------------------
"

systemctl enable cups.service
systemctl disable dhcpcd.service
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
if ! systemd-detect-virt &>/dev/null; then
  systemctl enable libvirtd.service
  usermod -aG libvirt "$USERNAME" &>/dev/null
fi
echo -ne "
--------------------------------------------------------------------
                              Cleaning 
--------------------------------------------------------------------
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

rm -r /root/"$BASENAME"

echo -ne "
--------------------------------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗██████╗  █████╗ ██╗   ██╗███████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗██║   ██║██╔════
  ███████║██████╔╝██║     ███████║██║  ██║███████║██║   ██║█████╗  
  ██╔══██║██╔══██╗██║     ██╔══██║██║  ██║██╔══██║╚██╗ ██╔╝██╔══╝ 
  ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝██║  ██║ ╚████╔╝ ███████╗
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
--------------------------------------------------------------------
            Done - Please Eject Install Media and Reboot
--------------------------------------------------------------------
"