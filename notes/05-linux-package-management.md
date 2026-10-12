# 05. Linux Package Management

RPM, DNF, dependencies, repositories and a local ISO repository experiment. The dependency failure and a tiny repo-file typo were useful lessons.

> Original lab notebook: approximately lines 1297–1697. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### RPM DOES NOT TAKE CARE OF DEPENDENCIES !!!!!

```console
# yum repolist
Updating Subscription Management repositories.
repo id                                  repo name
docker-ce-stable                         Docker CE Stable - x86_64
```

```console
$ cd /etc/yum.repos.d
```

```console
# rpm -q wget # check if the package is installed
```

```console
# rpm -ql wget #files installed by package
```

```console
# rpm -qi wget # detailed info about the package
```

```console
# yum info wget
Updating Subscription Management repositories.
Last metadata expiration check: 4:37:55 ago on Thu 23 Jul 2026 05:28:39 PM CEST.
Installed Packages
```

```console
# yum history
Updating Subscription Management repositories.
ID     | Command line                                       | Date and time    | Action(s)      | Altered
```

```console
# dnf history
Updating Subscription Management repositories.
ID     | Command line                                       | Date and time    | Action(s)      | Altered
```

### using yum

```console
# yum --help
```

```console
# yum search nano
Updating Subscription Management repositories.
Last metadata expiration check: 0:08:58 ago on Fri 24 Jul 2026 09:21:45 PM CEST.
============================== Name Exactly Matched: nano ==============================
```

```console
# yum info nano
Updating Subscription Management repositories.
Last metadata expiration check: 0:40:56 ago on Fri 24 Jul 2026 09:21:45 PM CEST.
Installed Packages
```

```console
# yum install nano
Updating Subscription Management repositories.
Last metadata expiration check: 0:42:06 ago on Fri 24 Jul 2026 09:21:45 PM CEST.
Package nano-8.1-3.el10.x86_64 is already installed.
```

### using rpm command

```console
# rpm --help
```

```console
# rpm -q nano
nano-8.1-3.el10.x86_64
```

```console
# rpm -ql nano
```

```console
# rpm -V nano
```

```console
# rpm -qf /usr/bin/nano
nano-8.1-3.el10.x86_64
```

### using yum for package installation and removal

```console
# sudo yum install httpd
Updating Subscription Management repositories.
Last metadata expiration check: 1:04:02 ago on Fri 24 Jul 2026 09:21:45 PM CEST.
Package httpd-2.4.63-13.el10_2.4.x86_64 is already installed.
```

```console
# rpm -q httpd
httpd-2.4.63-13.el10_2.4.x86_64
```

```console
# sudo yum remove httpd
Updating Subscription Management repositories.
Dependencies resolved.
=================================================================================
```

### using rpm for package installation and removal

```console
# dnf download httpd
Updating Subscription Management repositories.
Last metadata expiration check: 1:12:59 ago on Fri 24 Jul 2026 09:21:45 PM CEST.
httpd-2.4.63-13.el10_2.4.x86_64.rpm               77 kB/s |  57 kB     00:00
```

```console
# sudo rpm -ivh httpd-2.4.63-13.el10_2.4.x86_64.rpm
error: Failed dependencies:
httpd-core = 0:2.4.63-13.el10_2.4 is needed by httpd-2.4.63-13.el10_2.4.x86_64
system-logos(httpd-logo-ng) is needed by httpd-2.4.63-13.el10_2.4.x86_64
```

### creating local repositories

```console
# sudo mkdir -p /mnt/rhel
sudo mount -o loop /root/rhel-10.2-x86_64-dvd.iso /mnt/rhel
mount # mounts the file
-o loop # tells the system to treat the ISO file a physical disk
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Package operations I would use on a server

```bash
dnf repolist
dnf list installed
dnf info openssh-server
dnf history
dnf check-update
dnf updateinfo list security
rpm -qf /usr/sbin/sshd
rpm -V openssh-server
```

`rpm` is useful for inspecting local packages and package ownership, but installing an RPM directly may fail on dependencies, as it did in my httpd experiment. `dnf` resolves dependencies through repositories. On a production host I would review available security updates, service impact and rollback options before upgrading, rather than using `-y` by default.

A repository on RHEL installation media needs valid metadata locations. For DVD media that generally means distinct **BaseOS** and **AppStream** repository roots, not one assumed top-level `baseurl`. My `nam=` typo and the later cache refresh remain documented in the [local repo lab](../labs/local-dnf-repo.md).

`gpgcheck=0` is a lab shortcut, not a general recommendation.

## Related lab write-ups

- [Rpm dependencies](../labs/rpm-dependencies.md)
- [Local dnf repo](../labs/local-dnf-repo.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **4: Software Management**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
