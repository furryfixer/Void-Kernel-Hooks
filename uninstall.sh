#!/bin/bash
clear
echo "
##########################################################################
# VOID_KERNEL_HOOKS Uninstall script, by William Rueger (furryfixer)
# You must run with sudo or as root!
##########################################################################
"
if [ "$(id -u)" != "0" ]; then
   echo "Uninstall script must be run as root" 1>&2
   exit 1
fi
echo "
This script will remove only hooks installed by Void-kernel-hooks
from your system. Do you wish to continue?

Press [Y/N] and <ENTER>."
read yn
[[ $yn != [Yy] ]] && exit 1
echo "
To complete uninstall, Links must be removed from /boot directory.
This could make the system unbootable. You may manually edit grub.cfg
if preserving customization of that file, but there is risk. Either 
this must be done BEFORE REBOOTING, or the system may BECOME UNBOOTABLE.
It is strongly suggested to allow this script to update grub.cfg now.

OK to create run update-grub? 

Press [Y/N] and <ENTER>."
read yn
rm -fv /boot/vmlinuz-linux
rm -fv /boot/initramfs-linux.img
if [[ $yn = [Yy] ]]; then
	update-grub
fi
echo "
Uninstalling gksudo2...
"
[[ -f /etc/kernel.d/post-install/30-update-links ]] && rm -fv /etc/kernel.d/post-install/30-update-links
[[ -f /etc/kernel.d/pre-install/30-vkpurge ]] && rm -fv /etc/kernel.d/pre-install/30-vkpurge
[[ -f /etc/kernel.d/post-remove/30-repair-links ]] && rm -fv /etc/kernel.d/post-remove/30-repair-links
[[ -f /etc/kernel.d/pre-install/20-rm_grub ]] && rm -fv /etc/kernel.d/pre-install/20-rm_grub
[[ -f /etc/kernel.d/pre-remove/20-rm_grub ]] && rm -fv /etc/kernel.d/pre-remove/20-rm_grub

if [[ $yn = [Yy] ]]; then
	echo "update-grub successful. If no errors, system will be bootable."
else
	echo "Because you did not answer \"Yes\" above, You must manually
alter grub.cfg or run \"sudo update-grub\" BEFORE REBOOTING!"
fi
echo "
Files installed by Void-kernel-hooks successfully removed."
