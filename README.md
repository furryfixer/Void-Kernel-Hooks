# Void-Kernel-Hooks
Scripts specifically for Void Linux, to be placed in various /etc/kernel.d/ subdirectories and to link the most recently installed or upgraded kernel for a particular series or meta package to invariant names "vmlinuz-linux" and "initramfs-linux.img. This mimics the behavior of Arch linux for kernel upgrades. The hooks also remove older kernels from the /boot directory automatically.

**Extensively rewritten 6/2026! A new "kernel-set-default" script must be run, as fundamental changes were made to the way default links are assigned (see below)**

The default will link to the most recently installed/updated kernel for a chosen xbps package or meta package, regardless of higher/lower version number. **This allows the default to upgrade but track a desired kernel meta package or series**. e.g. **linux, linux-lts, linux-mainline, linux6.12.** Multiple kernel packages and their associated kernels may be present and updating, without altering the default track that the administrator wishes to boot by default. These scripts are provided under the GPL-3.0 license.

### Features
- Name assigned to default kernel never changes (update-grub becomes optional)
- Older kernels automatically purged with updates (prevents clutter in /boot)
- Default stays with preferred kernel series (easier to have multiple series)

## Installation
xbps and bash are required. The scripts included here are designed to be placed in respective subdirectories of /etc/kernel.d/. **Do NOT replace entire subdirectories because other essential kernel hooks will be erased which are not included here.**  To install, download all files in the repo, or:

git clone https://github.com/furryfixer/Void-Kernel-Hooks

Then from the download directory, run

- chmod +x install.sh
- chmod +x uninstall.sh
- sudo ./install.sh

In order to take advantage of the invariant kernel names, /boot/grub/grub.cfg may be customized, keeping generic link names as defaults. The scripts assume the Arch conventions, creating default links as follows:

- linux	>     /boot/vmlinuz-linux
- initrd >    /boot/initramfs-linux.img

Beware! Although unlikely, if the default link fails, or if grub.cfg is edited improperly, the system may become unbootable.

## Discussion:
After installing Void-Kernel-Hooks, the kernel link name, "vmlinuz-linux", will never change, but the target it links to in /boot will update instead. A **"kernel-set-default"** script is provided and should be used as needed. the "default" set here is NOT an individual kernel. Rather, it is an xbps kernel package or meta package.  **This allows the default to upgrade but lock onto a desired kernel series, such as: linux, linux-lts, linux-mainline, linux6.12 for example.**. Multiple xbps kernel packages can then be installed and updated at the same time, without randomly changing the default to any new kernel version. If "no series" is selected as default, the default link will target kernels regardless of version number or series, always linking the kernel most recently updated by xbps.
#### Preventing "grub-mkconfig or "update-grub" from executing with kernel upgrades ####
>This is optional. There are two reasons to consider it:
>
>(1) Speed! Particularly if os-prober will need to examine many disks/partitions.  
>(2) A custom grub.cfg file has significant edits that we want to preserve
>
>Disabling update-grub works best after first running it with GRUB_DISABLE_SUBMENU=y set in /etc/default/grub or by removing most advanced submenus from grub.cfg, leaving \"vmlinuz-linux\" and \"initramfs-linux.img\" as the only stanza for the default partition. This is because submenu entries will not update if kernels are updated or removed, and the advanced submenu will become outdated/inaccurate (but the default kernel entry will always still be correct). Although it will no longer happen automatically, you still have the ability to run \"sudo update-grub\" at any time to update the boot menu. 

The install script will offer the option for dracut to continue triggering update-grub, in which case it will still pick up the generic names as defaults. The install script will ask the user to set the initial default kernel series. If not using install.sh, run "kernel-set-default" (see below). The links will afterward point to the most recently installed kernel for the desired series, regardless of whether the version is higher than the previous one.

A vkpurge hook is included which will delete obsolete kernels, but preserve the kernel running at the time of the update (usually the most recent previous kernel). This prevents filling up the /boot directory with obsolete kernels.

"kernel-set-default" must be run to change the default kernel series. **It will not install kernel packages, and will not list every available xbps kernel package in the repos, but only those that are locally installed**. You must use xbps-install to add a kernel package before it will be offered as a default choice by the script. When the default is "no series" or no default is found, the hooks will still link a default kernel, without regard to which series, meta package, or version number. This is the previous behavior for these hooks. In that case, preference is given to the most recent kernel installed or updated, not the highest version number among kernels in /boot. 

Changes made by the installer may be reversed by running "sudo ./uninstall.sh" from the download directory. 
