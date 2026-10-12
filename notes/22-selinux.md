# 22. SELinux

Enforcing/permissive modes, file labels, booleans, port policies and AVC searches. Distinguishing a real denial from a guess matters here.

> Original lab notebook: approximately lines 12730–13264. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

```console
$ ls -Z
system_u:object_r:admin_home_t:s0 anaconda-ks.cfg
unconfined_u:object_r:admin_home_t:s0 backup.sh
unconfined_u:object_r:admin_home_t:s0 backup.tar
```

```console
# getenforce
Enforcing
```

```console
# sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
```

### troubleshoot web server access with SELinux

```console
# sudo ausearch -m avc -ts recent
<no matches>
```

```console
# sudo journalctl | grep SELinux
Aug 28 10:51:17 localhost kernel: SELinux:  Initializing.
Aug 28 10:51:24 localhost kernel: SELinux:  policy capability network_peer_controls=1
Aug 28 10:51:24 localhost kernel: SELinux:  policy capability open_perms=1
```

### Implementing SELinux Status

```console
# cat /etc/selinux/config
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
```

```console
# sestatus | grep policy
Loaded policy name:             targeted
Max kernel policy version:      33
```

```console
# getsebool httpd_can_network_connect
httpd_can_network_connect --> off
```

### Configuring SELinux Modes

```console
# setenforce 0
```

```console
# setenforce 1
```

```console
# sudo nano /etc/selinux/config
```

### Using Context Labels

```console
$ ls -lZ /root
total 31732
-rw-------. 1 root   root system_u:object_r:admin_home_t:s0          936 Apr 16 14:32 anaconda-ks.cfg
-rwxr-xr-x. 1 root   root unconfined_u:object_r:admin_home_t:s0       71 Jul 23 20:53 backup.sh
```

```console
$ ls -Z /etc/passwd
system_u:object_r:passwd_file_t:s0 /etc/passwd
```

```console
$ ls -ZR /root
/root:
system_u:object_r:admin_home_t:s0 anaconda-ks.cfg
unconfined_u:object_r:admin_home_t:s0 backup.sh
```

```console
# ps -eZ | grep systemd
system_u:system_r:init_t:s0           1 ?        00:00:01 systemd
system_u:system_r:syslogd_t:s0      918 ?        00:00:00 systemd-journal
system_u:system_r:systemd_userdbd_t:s0 958 ?     00:00:00 systemd-userdbd
```

### Performing SELinux Context Restoration and Change

```console
$ ls -Z /var/www/html/test/hello.html
```

```console
# chcon -t ssh_home_t /var/www/html/test/hello.html
```

```console
# restorecon /var/www/html/test/hello.html
-check
```

```console
# semanage fcontext -a -t httpd_sys_content_t '/var/www/html/test(/.*)?'
```

```console
# restorecon -Rv /var/www/html/test/hello.html
-check
```

### Implementing SELinux Boolean Settings

```console
# setsebool httpd_can_network_connect on
```

```console
# setsebool httpd_can_network_connect off
```

```console
# setsebool -P httpd_can_network_connect on
```

```console
# semanage boolean -l | grep nfs
colord_use_nfs                 (off  ,  off)  Allow colord to use nfs
ftpd_use_nfs                   (off  ,  off)  Allow ftpd to use nfs
git_cgi_use_nfs                (off  ,  off)  Allow git to cgi use nfs
```

### Configuring SELinux Policies

```console
# semodule -l
abrt
accountsd
acct
```

```console
# semanage port -l
SELinux Port Type              Proto    Port Number
afs3_callback_port_t           tcp      7001
afs3_callback_port_t           udp      7001
```

**About the SELinux mode tests:** my notes include temporary `setenforce` changes and an experiment setting permissive mode in the configuration. For a real denial I would keep enforcing enabled, read the AVC record and correct the context or policy instead of leaving SELinux permissive.

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### What I would inspect when access is denied

```bash
getenforce
sestatus
ls -lZ /srv/www
matchpathcon /srv/www/index.html
restorecon -nRv /srv/www
ausearch -m AVC,USER_AVC -ts recent
semanage fcontext -l | grep httpd
semanage port -l | grep ssh
```

SELinux context is a tuple of user, role, type and level. In common targeted policies, **type** is often the most relevant part of a file-label issue, but I shouldn't infer a denial from `unconfined_u` alone. I originally did that when looking at `ssh_home_t` files, and the note records the correction.

Use `semanage fcontext` to record a persistent file-context rule and `restorecon` to apply policy labels. `chcon` changes a label directly but is not the general long-term way to define a custom path rule. I would identify the AVC event before turning SELinux off, and would avoid blindly installing permissive policy exceptions. The real SSH/SELinux observations are kept under [labs](../labs/ssh-selinux-label-question.md).

## Related lab write-ups

- [Selinux context restore](../labs/selinux-context-restore.md)
- [Selinux boolean httpd](../labs/selinux-boolean-httpd.md)
- [Ssh selinux label question](../labs/ssh-selinux-label-question.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **8: Security-Enhanced Linux**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/security_hardening/index) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
