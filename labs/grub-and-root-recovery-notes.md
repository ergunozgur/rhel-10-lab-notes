# GRUB and root recovery: notes and precautions

Early in the course I wrote down the GRUB rescue and `rd.break` sequence used to enter an early boot shell, remount the installed system, change a root password and trigger an SELinux relabel. It made sense conceptually, but my notebook does **not** contain a complete, verified recovery transcript from an encrypted or production-style RHEL 10 installation.

The general recovery ideas I wrote down were:

- Know whether the installation uses BIOS or UEFI and how to reach the GRUB menu.
- Early boot and installed-root filesystems are not necessarily the same environment.
- A password change outside the normal SELinux context can require relabeling on next boot.
- An encrypted filesystem still needs its unlock method; access to GRUB doesn't bypass disk encryption.

A generic five-command rescue recipe would be misleading. Bootloader and rescue-mode details vary by installation, and mistakes can leave a system unbootable. These are the recovery concepts from my training notes; the notebook does not contain a full recovery transcript. For a real recovery, follow the documentation for that host and take a VM snapshot before practising.
