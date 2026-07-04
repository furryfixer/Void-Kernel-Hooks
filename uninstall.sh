#!/bin/bash
##########################################################################
# VOID_KERNEL_HOOKS Uninstall script, by William Rueger (furryfixer)
# You must run with sudo or as root!
##########################################################################

if [ "$(id -u)" != "0" ]; then
   echo "Uninstall script must be run as root" 1>&2
   exit 1
fi
clear
echo "VOID_KERNEL_HOOKS Uninstall

This script will remove extra /etc/kernel.d/ hooks installed by
Void-Kernel-Hooks. If grub or efibootmgr hooks are missing, their
respective packages will be reinstalled. All other associated files
will be removed with the exception of two links in /boot. These are
NOT removed, because this could make the partition unbootable,
especially wih a stripped-down customized \"grub.cfg\". Also, if you
boot from another partition, running update-grub on this one will NOT
make this partition bootable.

For this reason, you will need to assume the responsibility of manually
removing \"\boot\vmlinuz-linux\" and \"\boot\initramfs-linux.img\" and
making sure your boot configuration is good. If grub uses the grub.cfg
file from THIS partition, running of sudo update-grub after link removal
should be sufficient, but double-check BEFORE rebooting.

Do you wish to continue?

Press [Y/N] and <ENTER>."
read yn
[[ $yn != [Yy] ]] && exit 1
grub_state=$(xbps-query -p state grub)
efi_state=$(xbps-query -p state efibootmgr)
if [[ $grub_state = "installed" ]] && [[ ! -f /etc/kernel.d/post-install/50-grub ]]; then
	echo "
Reinstalling grub to restore grub hooks"
	xbps-install -yf grub
fi
if [[ $efi_state = "installed" ]] && [[ ! -f /etc/kernel.d/post-install/50-efibootmgr ]]; then
	echo "
Reinstalling efibootmgr to restore efibootmgr hooks"
	xbps-install -yf efibootmgr
fi
echo "
Uninstalling Void-Kernel-Hooks...
"
rm -vf /etc/kernel.d/post-install/30-update-links
rm -vf /etc/kernel.d/pre-install/30-vkpurge
rm -vf /etc/kernel.d/post-remove/30-repair-links
rm -vf /etc/kernel.d/pre-install/20-rm_grub
rm -vf /etc/kernel.d/pre-remove/20-rm_grub
rm -vf /etc/krnl-series-default
rm -vf /usr/local/bin/kernel-set-default
rm -vf /usr/bin/kernel-set-default
rm -vf /etc/knrl-series-default

echo "
Files installed by Void-Kernel-Hooks except links in /boot successfully removed.

Exiting..."
exit 0
