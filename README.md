# RHEL 10 Lab Notes

My notes from 22 Red Hat System Administrator courses completed through **Skillsoft Percipio** (my employer’s learning portal). The course material followed an RHCSA-oriented path; I did the hands-on work on a **RHEL 10 VM in VirtualBox**.

This is my working notebook, organized so I can look things up later: commands I ran, terminal results, things that failed, fixes, and extra reference material that is useful beyond a lab. It is not an official Red Hat guide. I completed the training path, **not the RHCSA/EX200 certification exam**.

## Getting started

Before the 22 course sections, I added some background and setup notes: [what RHEL is](getting-started/01-red-hat-and-rhel.md), [installing RHEL 10 in VirtualBox](getting-started/02-installing-rhel-10-in-virtualbox.md), [registration and first updates](getting-started/03-first-boot-and-repositories.md), and [VM networking / SSH](getting-started/04-virtualbox-networking-and-ssh.md). These are extra references, **not additional course completions**.

## The 22 course sections

I kept the same order as my training notebook instead of merging several courses into one broad topic.

01. [Command Line Essentials](notes/01-command-line-essentials.md)
02. [Advanced Command Line Techniques](notes/02-advanced-command-line-techniques.md)
03. [Managing Files](notes/03-managing-files.md)
04. [Help Commands and Text Editing](notes/04-help-commands-and-text-editing.md)
05. [Linux Package Management](notes/05-linux-package-management.md)
06. [Shell Scripting](notes/06-shell-scripting.md)
07. [Analyzing and Storing Logs](notes/07-analyzing-and-storing-logs.md)
08. [Analyzing Servers](notes/08-analyzing-servers.md)
09. [Storage and Logical Volume Management (LVM)](notes/09-storage-and-logical-volume-management.md)
10. [Containers](notes/10-containers.md)
11. [Access File Systems](notes/11-access-file-systems.md)
12. [Accessing Network File Systems (NFS)](notes/12-accessing-network-file-systems-nfs.md)
13. [Process Monitoring and Management](notes/13-process-monitoring-and-management.md)
14. [Control Services and Daemons](notes/14-control-services-and-daemons.md)
15. [Scheduling Tasks](notes/15-scheduling-tasks.md)
16. [User and Group Management](notes/16-user-and-group-management.md)
17. [Linux Networking](notes/17-linux-networking.md)
18. [Firewalls](notes/18-firewalls.md)
19. [File Permissions and Ownership](notes/19-file-permissions-and-ownership.md)
20. [Access Control Lists (ACLs)](notes/20-access-control-lists-acls.md)
21. [Secure SSH Configuration](notes/21-secure-ssh-configuration.md)
22. [SELinux](notes/22-selinux.md)

## Lab write-ups

The [labs folder](labs/) keeps a closer look at the things I tried: SSH authentication and SELinux ports, ACL masks, LVM resizing, NFS mounts, Podman volumes, service timers and more. A failed command is left as a failed command, with an explanation, rather than quietly changed into a successful test.

## Quick reference

The [reference guides](reference/README.md) include operational notes for SSH, SELinux, firewall changes, NFS, disk pressure, LVM, logs and containers. The small [Bash and systemd examples](scripts/README.md) came from the lab exercises with a few corrections.

## Scope and safety

The notebook combines actual VM observations with clearly labelled **additional reference commands**. Some additions draw on an RHEL 9 study guide and were compared with RHEL 10 documentation; this does **not** mean the original lab ran those additional commands.

The published version excludes passwords, hashes, private keys, personal environment details, course PDFs and certificate documents. Some operations in this notebook can destroy data or cut off remote access, particularly `fdisk`, `mkfs`, `xfs_repair`, `systemctl`, SSH and firewall changes. Never run them against a real machine without identifying the target, validating the plan and having a rollback path.

See [course coverage](reference/COURSE_COVERAGE.md) and [sources and scope](reference/sources-and-scope.md).
