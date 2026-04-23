# Void-Kernel-Hooks
Scripts specifically for Void Linux, to be placed in various /etc/kernel.d/ subdirectories and to link the most recently installed kernel to an invariant name for grub. This mimics the behavior of Arch linux when it comes to kernel upgrades. The hooks also run vkpurge to remove older kernels from the /boot directory.
#### 4/2026 updates include addition of Install and uninstall scripts, and changing default links to point to the most recently added kernel, not necessarily the highest version.
 
The scripts included here are designed to be placed in respective subdirectories of /etc/kernel.d/. **Do NOT replace entire subdirectories because other essential kernel hooks will be erased which are not included here.**  To install, download the folders/files, or better,

git clone https://github.com/furryfixer/Void-Kernel-Hooks

Then from the download directory, run

- chmod +x install.sh
- chmod +x uninstall.sh
- ./install.sh

In order to take advantage of the invariant kernel names, /boot/grub/grub.cfg may be edited to default to the generic link names. As written, the scripts assume the Arch conventions, namely

- linux	>     /boot/vmlinuz-linux
- initrd >    /boot/initramfs-linux.img

## Discussion:
Void invokes dracut for kernel updates and some module updates. After installing Void-kernel-hooks, the default kernel, regardless of version, will always retain the generic name in /boot and be linked to the most recent kernel installed. If approved, pre-existing hooks "50-efibootmgr" and "50-grub" will be removed, as running update-grub or changing bootloader is unneccesary when using these new hooks. This allows all custom edits to /boot/grub.cfg to be preserved if desired, and may significantly speed up dracut if there are many bootable partitions and os-prober is in use. 

Disabling update-grub works best if the only stanza in grub.cfg for the default partition is for \"vmlinuz-linux\" and \"initramfs-linux.img\", because other menu entries will not update if kernels are removed, and the boot menu will become inaccurate (but the default kernel entry will always still be correct). Although dracut will not do it for you, you still have the ability to run \"sudo update-grub\" at any time to update your boot menu. 

In summary, disabling grub updates may be desirable for two reasons:

(1) Speed! Particularly if os-prober will need to examine many disks/partitions.  
(2) The grub.cfg file has significant edits that we want to preserve

The install script will offer the option for dracut to continue triggering update-grub, in which case it will still pick up the generic names as defaults. When first installed, the links will initially point to the currently running kernel version if found in the /boot directory, and this will become the default. The links will afterward point to the most recently installed kernel, regardless of whether the version is higher than the previous one (this was not true prior to recent updates).

A vkpurge hook is included which will delete obsolete kernels, but preserve the kernel running at the time of the update (usually the most recent previous kernel). This prevents filling up the /boot directory with obsolete kernels.

The changes may be completely reversed by running "sudo uninstall.sh".
