#!/bin/bash
#################################################################
# VOID-KERNEL-HOOKS install script, by William Rueger (furryfixer)
# Offered under GPL-3.0 license 
#################################################################
clear
echo "VOID-KERNEL-HOOKS Install

Designed for Void Linux only! Links with standard names will be
created in \boot for the current kernel in a chosen xbps package.
The unchanging names for the links will be \"vmlinuz-linux\" and
\"initramfs-linux.img\". Running of update-grub or grub-mkconfig
will become optional with kernel updates. Problems are rare, but
could make your system unbootable. Use at your own risk! The
default kernel linked will change with upgrades, but track a
desired kernel meta package or series. Examples include 
(linux|linux-lts|linux-mainline|linux6.12). Default links will
ignore upgrades to other kernels in /boot regardless of version
numbers. This allows multiple kernel packages to co-exist without
randomly altering the boot default series. To undo all changes,
run the provided \"uninstall.sh\" script.

Do you wish to continue?
Press [y/n] and <ENTER>."
read yn
[[ $yn != [Yy] ]] && exit 1
# user must be root
if [ "$(id -u)" != "0" ]; then
   echo "Installation must be run as root. Exiting"
   exit 1
fi
if ! ls -A /boot >/dev/null 2>&1 ; then
	echo "/boot directory is not mounted or is empty.
Exiting..."
	exit 1
fi
if [[ ! -d /etc/kernel.d/post-install ]] || [[ ! -d /etc/kernel.d/post-remove ]] \
	|| [[ ! -d /etc/kernel.d/pre-install ]] || [[ ! -d /etc/kernel.d/pre-remove ]]; then
	echo "Required /etc/kernel.d hook directories are missing. Is this Void Linux?

Exiting...
"
	exit 1
fi
echo "
The option is offered to prevent dracut from calling
update-grub/grub-mkconfig, as updating grub becomes unnecessary
when using these hooks. Even when disabled, you will retain the
ability to run \"sudo update-grub\" at any time if needed. If
approved, pre-existing hooks \"50-efibootmgr\" and \"50-grub\"
will be removed. This allows any custom edits to grub.cfg to
be preserved, and may significantly speed up dracut if there
are many bootable partitions and os-prober is in use. See
README.md or Github repo Readme for guidance on generating a
suitable grub.cfg for this option, whether custom editing or not.

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
fi
echo "Press <Enter> to continue..."
read a
echo "Installing Void kernel hooks...
Collating new files...
"
echo "/etc/kernel.d/post-install/30-update-links
/etc/kernel.d/pre-install/30-vkpurge
/etc/kernel.d/post-remove/30-repair-links
/etc/kernel.d/pre-install/20-rm_grub
/etc/kernel.d/pre-remove/20-rm_grub" > /tmp/vkh-targets

echo "post-install/30-update-links
pre-install/30-vkpurge
post-remove/30-repair-links
pre-install/20-rm_grub
pre-remove/20-rm_grub
kernel-set-default" > /tmp/vkh-src

fullpathfound=true
while IFS= read -r fname; do ## Assume full path if git clone
	if [[ ! -f "$fname" ]]; then
		fullpathfound=false
		break 
	fi
done < "/tmp/vkh-src"
if [[ $fullpathfound = false ]]; then ## check for individual files instead of git clone
	echo "30-update-links
30-vkpurge
30-repair-links
20-rm_grub
20-rm_grub
kernel-set-default" > /tmp/vkh-src
	while IFS= read -r fname; do
		if [[ ! -f "$fname" ]]; then
			echo "install.sh must be run from within directory containing the git clone
or a download directory with all new hooks and the \"kernel-set-default\" file present.
One or more required files not found in $(pwd).
  
Exiting...
"
			exit 1
		fi
	done < "/tmp/vkh-src"
fi
## Files confirmed present
if [[ $rm_grub_hook -eq 1 ]]; then
	sed -i '6,$d' /tmp/vkh-src ## remove kernel-set-default
else
	sed -i '4,$d' /tmp/vkh-src ## remove 20_rm_grub
	sed -i '4,$d' /tmp/vkh-targets
fi
while IFS= read -r src <&3 && IFS= read -r target <&4; do
	cp -v "$src" "$target"
	chmod 0755 "$target"		
done 3< /tmp/vkh-src 4< /tmp/vkh-targets
rm -f /tmp/vkh-targets
rm -f /tmp/vkh-src
## Check PATH
if grep -q "/usr/local/bin" <<< $PATH; then
	prefix="/usr/local/bin"
	mkdir -p /usr/local/bin
else
	prefix="/usr/bin"
fi
cp -v kernel-set-default ${prefix}/kernel-set-default
chmod 0755 ${prefix}/kernel-set-default
echo "
If no errors, hooks were successfully installed, but a first-run version
of \"kernel-set-default\" is needed to activate them, and follows now.
Press <Enter> to continue..."
read a

echo "
You will now be asked which kernel package series is to be used
as default for grub boot. The default will follow updates to
the relevant xbps kernel package. The default may be a 
meta package (linux|linux-lts|linux-mainline) or a specific series
(e.g linux6.18). Designating a default series prevents being led
astray by updates to non-default packages, which may install kernels
with later/higher version numbers in /boot. If \"no series\" is
chosen, the default will link to the kernel most recently installed
or updated by xbps, regardless of package/series.

Press <Enter> to continue."
read a
# user must be root
if [ "$(id -u)" != "0" ]; then
	echo "Installation must be run as root. Exiting"
	exit 1
fi
if ! ls -A /boot >/dev/null 2>&1 ; then
	echo "/boot directory is not mounted or is empty.
Exiting..."
	exit 1
fi
echo "
Default names will be the links  \"vmlinuz-linux\" and
\"initramfs-linux.img\" corresponding to Arch conventions.
It is assumed that the /boot directory is mounted, and the kernels
to be booted are stored there.
------------------------------

Press <Enter> to continue..."

xbps-query -l | grep 'kernel meta' | awk '{ print $2 }' | xargs xbps-uhelper getpkgname > /tmp/kern-series
sed -i 's/$/ meta package/' /tmp/kern-series
xbps-query -l | grep 'linux' | grep 'series)' | grep -v 'headers' | awk '{ print $2 }' | xargs xbps-uhelper getpkgname >> /tmp/kern-series
echo "no series (default = kernel updated last by xbps)" >> /tmp/kern-series
clear
echo "
If a desired kernel package does not appear in this local list, choose
an alternative or \"no series\" for now, and after this installer completes,
xbps-install the missing kernel package or metapackage. After that,
separately run \"kernel-set-default\" from the command line.
"
i=1
while IFS= read -r kseries; do
	echo "(${i}) "$kseries
	((i++))
done < "/tmp/kern-series"
echo "
From the above list, enter the number from the first column for
the kernel series that you would like boot default to track,
followed by <Enter> key
"
read num
kdef_verbose=$(cat /tmp/kern-series | head -n $num | tail -n1)
echo "
The default series will be

\"$kdef_verbose\"

Is this correct? Press (y/n) <Enter>"
read yn
if [[ $yn = [Yy] ]]; then
	if grep -q 'no series' <<< $kdef_verbose ; then # no default
		rm -f /etc/krnl-series-default
		kdefault=""
	else
		echo $kdef_verbose > /etc/krnl-series-default
		kdefault=$(cut -d' ' -f1 <<< $kdef_verbose)	
		if grep -q 'meta package' <<< $kdef_verbose ; then
			pkgname=$(xbps-query -x $kdefault | head -n1 | cut -d'>' -f1)
		else
			pkgname=$kdefault	
		fi
		pkgver=$(xbps-query -p pkgver $pkgname | cut -d'-' -f2)
		INITRAMFS="initramfs-${pkgver}.img"
		VMLINUZ="vmlinuz-${pkgver}"
		if [ ! -e "/boot/${INITRAMFS}" ] || [ ! -e "/boot/${VMLINUZ}" ]; then
			echo "
Matching kernel version or initramfs in /boot does not exist for $kdefault.
Unable to set default. Package may need updated or is broken.
Install will finish without default set, but you will need to run
\"kernel-set-default\" separately after.
"
			kdefault=""
		else 
			ln -svf /boot/$INITRAMFS /boot/initramfs-linux.img
			ln -svf /boot/$VMLINUZ /boot/vmlinuz-linux
			echo "The \"vmlinuz-linux\" default now linked to the current kernel for
--  $kdef_verbose  --"
		fi
	fi
	rm -f /tmp/kern-series
else
	echo "
A DEFAULT WAS NOT SET! Install will finish without it, but you
should consider running \"kernel-set-default\" separately after.
	
Press <Enter>..."
	read a
fi
if [[ $kdefault = "" ]]; then
	echo "Linking default to latest kernel in /boot" 
	ls -c /boot/vmlinuz* | grep -v 'linux' > /tmp/vmlinuz
	while IFS= read -r vmline; do
    		versn_match=$(cut -d'-' -f2 <<< $vmline)
		if [[ -e "/boot/initramfs-${versn_match}.img" ]]; then
			ln -svf /boot/initramfs-${versn_match}.img /boot/initramfs-linux.img 
			ln -svf $vmline /boot/vmlinuz-linux
			break
		fi
	done < /tmp/vmlinuz
	rm -f /tmp/vmlinuz
fi
## End kernel-set-default first run
echo "
If no errors, Void-Kernel-Hooks installation succeeded."
if [ ! -f /etc/krnl-series-default ]; then
	echo "No default series or meta package was set.
Please run \"kernel-set-default\" to set default."
fi
echo "
A script is provided in the git repository to uninstall
Void-kernel-hooks. Run as root or sudo \"uninstall.sh\".
"
if [[ $rm_grub_hook -eq 0 ]]; then
	echo "
update-grub will now be triggered as installer completes.
Press <Enter> to continue..."
	read a
	echo "Exiting...
"
	exec update-grub
else ## disabling automatic update-grub
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
echo "
Exiting..."
exit
