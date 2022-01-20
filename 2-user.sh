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

# You can solve users running this script as root with this and then doing the same for the next for statement. However I will leave this up to you.
if [ $(whoami) = "root"  ]; then
  echo "Don't run this as root!"
  exit
fi
git clone "https://github.com/d4ve10/dotfiles.git" ~/.dotfiles
source ~/.dotfiles/install.sh


echo -ne "
-------------------------------------------------------------------------
                             Installing YAY
-------------------------------------------------------------------------
"

cd ~
git clone "https://aur.archlinux.org/yay.git"
cd ~/yay
makepkg -si --noconfirm
cd ~

echo -ne "
-------------------------------------------------------------------------
                         Installing AUR Packages
-------------------------------------------------------------------------
"

sed -e "/^#/d" -e "s/ #.*//" -e 's/ //g' ${SCRIPT_DIR}/packages/aur-minimal.txt | yay -S --needed --noconfirm -

source $SCRIPT_DIR/functions/kde-import.sh

cat <<EOF > ~/.config/plasma-localerc
[Formats]
LANG=en_US.UTF-8
LC_COLLATE=C
LC_MEASUREMENT=en_DE.UTF-8
useDetailed=true
EOF

echo -ne "
-------------------------------------------------------------------------
                    System ready for 3-post-setup.sh
-------------------------------------------------------------------------
"
exit
