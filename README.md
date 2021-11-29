# Void-Kernel-Hooks
Scripts to be placed in various /etc/kernel.d/ subdirectories to link the latest kernel to an invariant name for grub.

The scripts included here are designed to be placed in respective subdirectories of /etc/kernel.d/. Do NOT replace entire subdirectories because other essential kernel hooks will be erased which are not included here.  Instead simply (as root) copy each desired file into the existing subdirectory which corresponds to the folder here, or in your git clone. You may need to chmod +x to make sure the file is executable.
