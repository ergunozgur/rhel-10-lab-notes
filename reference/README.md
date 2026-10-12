# Things I want to remember on a real server

These pages are practical checklists for situations I might run into later. Some came from gaps I noticed while reviewing my RHCSA-oriented training notes and a RHEL 9 study guide; I cross-checked the operational ideas against **RHEL 10 Red Hat documentation**. They are *not* claims that I implemented every procedure.

- [What to inspect before changing a service](systemd-incident.md)
- [SSH hardening without locking myself out](ssh-safe-changes.md)
- [Diagnosing SELinux without turning it off](selinux-troubleshooting.md)
- [Disk pressure, I/O and logs](disk-pressure.md)
- [Growing an LVM and its filesystem](lvm-growth.md)
- [Network connectivity in a sensible order](network-diagnostics.md)
- [Firewalld zones and the difference between runtime and permanent](firewalld-change-safety.md)
- [NFS access and common export mistakes](nfs-troubleshooting.md)
- [Podman volumes, SELinux and persistent services](podman-in-production.md)
- [DNF, repositories and safe patching](package-maintenance.md)
- [Accounts, sudo and ACL troubleshooting](permissions-audit.md)
- [Backups and recovery checks](backup-and-recovery.md)
- [Sources, versions and verification](sources-and-scope.md)

I deliberately keep these separate from [labs/](../labs/). A command can be good documentation without having been run in my VM. I'm not going to blur that distinction.
