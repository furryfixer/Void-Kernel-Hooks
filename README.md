# Void-Kernel-Hooks
Scripts to be placed in various /etc/kernel.d/ subdirectories to link the latest kernel to an invariant name for grub.

The scripts included here are designed to be placed in respective subdirectories of /etc/kernel.d/. Do NOT replace entire subdirectories because other essential kernel hooks will be erased which are not included here.  Instead simply (as root) copy each desired file into the existing subdirectory which corresponds to the folder here, or in your git clone. You may need to chmod +x to make sure the file is executable.

In order to work, /boot/grub/grub.cfg must be edited to default to the desired link names.  As written, the scripts assume the Arch conventions, namely

- linux	  /boot/vmlinuz-linux
- initrd	/boot/initramfs-linux.img

A vkpurge hook is included which will delete obsolete kernels, but preserve at least the most recent previous kernel.  Links for grub are changed to the newest kernel by default.
