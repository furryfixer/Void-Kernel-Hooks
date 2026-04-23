#!/bin/bash
clear
echo "
#################################################################
# VOID-KERNEL-HOOKS install script, by William Rueger (furryfixer)
# Designed for Void Linux only! Links with standard names will
# be created in \boot for newly installed kernels, named
# \"vmlinuz-linux\" and \"initramfs-linux.img\". The permanent
# names make running update-grub or grub-mkconfig optional.
# Run this script with sudo or as root.  Problems are very rare,
# but if they occur, your system may become unbootable.
# Use at your own risk! By installing this software,
# you are accepting the benefits and limitations of the 
# GPL 3 license.
#################################################################"
echo "
Do you wish to continue?

Press [y/n] and <ENTER>."
read yn
[[ $yn != [Yy] ]] && exit 1
# user must be root
if [ "$(id -u)" != "0" ]; then
   echo "Installation must be run as root. Exiting" 1>&2
   exit 1
fi
if [[ ! -d /etc/kernel.d/post-install ]] || [[ ! -d /etc/kernel.d/post-remove ]] \
	|| [[ ! -d /etc/kernel.d/pre-install ]] || [[ ! -d /etc/kernel.d/pre-remove ]]; then
	echo "Required /etc/kernel.d hook directories are missing. Is this Void Linux?

Exiting...
"
	exit 1
fi
echo "Installing Void kernel hooks...
Collating new files...
"
targetfiles=(
"post-install/30-update-links"
"pre-install/30-vkpurge"
"post-remove/30-repair-links"
"pre-install/20-rm_grub"
"pre-remove/20-rm_grub"
)
if [[ -f post-install/30-update-links ]] && [[ -f post-remove/30-repair-links ]] \
	&& [[ -f pre-install/30-vkpurge ]] && [[ -f pre-remove/20-rm_grub ]]; then
	srcfiles=("${targetfiles[@]}")
else	## check for individual files instead of git clone
	if [[ -f 30-update-links ]] && [[ -f 30-repair-links ]] \
	&& [[ -f 20-rm_grub ]] && [[ -f 30-vkpurge ]]; then
	srcfiles=(
"30-update-links"
"30-vkpurge"
"30-repair-links"
"20-rm_grub"
"20-rm_grub"
)
	else
		echo "install.sh must be run from within directory containing
the git clone or a download directory with all new hooks present.
One or more required files not found in $(pwd).
  
Exiting...
"
		exit 1
	fi
fi
echo "
Dracut is invoked for kernel updates and some module updates. After installing
Void-kernel-hooks, the default kernel, regardless of version, will always be
called \"vmlinuz-linux\" in /boot and linked to the most recent kernel installed,
so you have the option to prevent dracut from running update-grub/grub-mkconfig.

This works best if the only stanza in grub.cfg for the default partition is for
\"vmlinuz-linux\" and \"initramfs-linux.img\", because other menu entries 
will not update if kernels are removed, and the boot menu will be inaccurate.
The first/default kernel entry will always still boot in this case.
You will also still have the ability to run \"sudo update-grub\" at any time
if needed. Disabling grub updates may be desirable for two reasons:

(1) Speed! Particularly if os-prober will need to examine many disks/partitions.
(2) The grub.cfg file has significant edits that we want to preserve

Given this information, Disable dracut's use of update-grub?
Press [y/n] and <ENTER>."
read yn
if [[ $yn = [Yy] ]]; then
	rm_grub_hook=1
	echo "
grub-update will not run with dracut"
else
	rm_grub_hook=0
	echo "
grub-update will continue to run with dracut"
	sleep 2
fi
[[ $rm_grub_hook -eq 1 ]] && j=5 || j=3	
for (( i=0; i<$j; i++ )); do
	cp -v ${srcfiles[$i]} /etc/kernel.d/${targetfiles[$i]}
	chmod 0744 /etc/kernel.d/${targetfiles[$i]}
done
if [[ ! -a "/boot/vmlinuz-linux" ]] || [[ ! -a "/boot/initramfs-linux.img" ]]; then
	## Create missing links to the currently running kernel version in /boot  
	VRSN=$(uname -r)
	ln -sf /boot/initramfs-${VRSN}.img  /boot/initramfs-linux.img
	ln -sf /boot/vmlinuz-${VRSN} /boot/vmlinuz-linux
	echo "Kernel booted by grub.cfg, <vmlinuz-linux> successfully relinked to "$VRSN
fi
echo "
The initial links created will default to the highest version kernel
found in /boot, unless you manually alter the links.
"
[[ $rm_grub_hook -eq 0 ]] && update-grub
echo "
If no errors, installation succeeded.

A script is provided in the git repository to uninstall
Void-kernel-hooks. Run as root or sudo \"uninstall.sh\".
"
if [[ $rm_grub_hook -eq 1 ]]; then
	echo "
***NOTE: Since you are preserving your existing grub.cfg file, you
MUST manually edit it to modify the default (or add a) stanza with
	 \"vmlinuz-linux\" and \"initramfs-linux\"
instead of version numbers. You only need to do this once, but should
do it now, or run sudo update-grub, before any kernels are removed,
or the system could become unbootable!
You have been warned!
"
fi
exit
