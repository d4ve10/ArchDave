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

$SCRIPT_DIR/functions/pacman.sh

pacman -S --noconfirm --needed terminus-font
setfont ter-v22b

echo -ne "
--------------------------------------------------------------------
                      Installing Prerequisites
--------------------------------------------------------------------
"
pacman -S --noconfirm --needed archlinux-keyring gptfdisk grub btrfs-progs xfsprogs dosfstools e2fsprogs

mkdir /mnt &>/dev/null
swapoff -a &>/dev/null
umount -R /mnt &>/dev/null
unset BOOT_PARTITION
unset ROOT_PARTITION
unset SWAP_PARTITION
unset SWAP_TYPE
unset HIBERNATE_TYPE

source "$SCRIPT_DIR/dialogs/mainmenu.sh"

if [[ -z "$BOOT_PARTITION" ]] || [[ -z "$ROOT_PARTITION" ]]; then
    source $SCRIPT_DIR/functions/exit.sh
fi


mount "$ROOT_PARTITION" /mnt
mkdir /mnt/boot &>/dev/null
mount "$BOOT_PARTITION" /mnt/boot/

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted, can not continue"
    source $SCRIPT_DIR/functions/exit.sh
fi

echo "DISK=$DISK" >> "$SCRIPT_DIR/install.conf"
echo "BOOT_PARTITION=$BOOT_PARTITION" >> "$SCRIPT_DIR/install.conf"
echo "ROOT_PARTITION=$ROOT_PARTITION" >> "$SCRIPT_DIR/install.conf"
[ -n "$SWAP_PARTITION" ] && echo "SWAP_PARTITION=$SWAP_PARTITION" >> "$SCRIPT_DIR/install.conf"
[ -n "$SWAP_TYPE" ] && echo "SWAP_TYPE=$SWAP_TYPE" >> "$SCRIPT_DIR/install.conf"
[ -n "$HIBERNATE_TYPE" ] && echo "HIBERNATE_TYPE=$HIBERNATE_TYPE" >> "$SCRIPT_DIR/install.conf"

$SCRIPT_DIR/functions/mirrors.sh

echo -ne "
--------------------------------------------------------------------
                     Arch Install on Main Drive
--------------------------------------------------------------------
"
pacstrap /mnt --noconfirm --needed base base-devel linux linux-firmware vim nano sudo archlinux-keyring wget git libnewt fprintd grub
$SCRIPT_DIR/functions/swap.sh /mnt
echo "# <file system> <dir> <type> <options> <dump> <pass>" > /mnt/etc/fstab
genfstab -U /mnt >> /mnt/etc/fstab
! grep -q "keyserver.ubuntu.com" /mnt/etc/pacman.d/gnupg/gpg.conf && echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
cp -R "${SCRIPT_DIR}" /mnt/root
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
echo -ne "
--------------------------------------------------------------------
                     System ready for 1-setup.sh
--------------------------------------------------------------------
"
