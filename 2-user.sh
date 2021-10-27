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
git clone "https://github.com/d4ve10/dotfiles.git" "$HOME/.dotfiles"
source "$HOME/.dotfiles/install.sh"


echo "--------------------------------"
echo "          CLONING: YAY          "
echo "--------------------------------"

cd ~
git clone "https://aur.archlinux.org/yay.git"
cd ${HOME}/yay
makepkg -si --noconfirm
cd ~

echo "-------------------------------------------"
echo "          INSTALLING AUR SOFTWARE          "
echo "-------------------------------------------"
PKGS=(
'anydesk-bin'
'arc-kde'
'autojump'
'brave-bin' # Brave Browser
'ckb-next-git'
'cups-bjnp'
'dxvk-bin' # DXVK DirectX to Vulcan
'etcher-bin'
'github-desktop-bin' # Github Desktop sync
#'lightly-git'
#'mangohud' # Gaming FPS Counter
#'mangohud-common'
'minecraft-launcher'
'intellij-idea-ultimate-edition'
'intellij-idea-ultimate-edition-jre'
'ocs-url' # install packages from websites
'phpstorm'
'phpstorm-jre'
'pycharm-professional'
'rambox-bin'
'rtl88x2bu-dkms-git'
#'sddm-nordic-theme-git'
'timeshift'
'ttf-droid'
'ttf-hack'
'ttf-meslo' # Nerdfont package
'ttf-roboto'
'ttf-ms-fonts'
'typora'
'ventoy-bin'
'zenmap'
'zoom' # video conferences
#'snapper-gui-git'
#'snap-pac'
)

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

source $SCRIPT_DIR/functions/kde-import.sh

cat <<EOF > ~/.config/plasma-localerc
[Formats]
LANG=en_US.UTF-8
LC_COLLATE=C
LC_MEASUREMENT=en_DE.UTF-8
useDetailed=true
EOF

echo -e "\nDone!\n"
exit
