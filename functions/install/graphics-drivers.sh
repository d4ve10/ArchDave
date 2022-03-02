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

echo -ne "
--------------------------------------------------------------------
                     Installing Graphics Drivers
--------------------------------------------------------------------
"

if lspci | grep -Eq "NVIDIA|GeForce"; then
	pacman -S --noconfirm --needed nvidia nvidia-lts nvidia-settings nvidia-utils lib32-nvidia-utils lib32-opencl-nvidia
	nvidia-xconfig
	echo "options nvidia_drm modeset=1" > /usr/lib/modprobe.d/nvidia-drm.conf
	#cp "$SCRIPT_DIR/nvidia.conf" "/etc/X11/xorg.conf.d/"
fi

if lspci | grep 'VGA' | grep -Eq "Radeon|AMD"; then
	pacman -S --noconfirm --needed xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon
fi

if lspci | grep "VGA" | grep "Intel" | grep -q "Graphics"; then
	pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
fi