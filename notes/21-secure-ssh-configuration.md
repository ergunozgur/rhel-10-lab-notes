# 21. Secure SSH Configuration

SSH keys, authentication, configuration precedence, login limits, alternate ports and SELinux. I kept the failures instead of presenting them as perfect setups.

> Original lab notebook: approximately lines 11804–12729. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### Secure Shell (SSH)

```console
# cat /etc/ssh/sshd_config
#       $OpenBSD: sshd_config,v 1.104 2021/07/02 05:11:21 dtucker Exp $
# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.
```

### Configuring SSH

```console
$ ls -l /etc/ssh/ | grep sshd
-rw-------. 1 root root   3674 Jul 14 02:00 sshd_config
-rw-------. 1 root root   3674 Oct 11 16:19 sshd_config.bak
drwx------. 2 root root     97 Jul 14 02:00 sshd_config.d
```

```console
# nano /etc/ssh/sshd_config
```

```console
# sshd -t
```

```console
# systemctl restart sshd
```

```console
# systemctl status sshd
● sshd.service - OpenSSH server daemon
Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; preset: enabled)
Active: active (running) since Sun 2026-10-11 16:26:04 CEST; 51s ago
```

```console
# useradd mike
-set password
```

```console
# passwd mike
New password:
Retype new password:
passwd: password updated successfully
```

```console
# su - mike
```

```console
# nano /etc/ssh/sshd_config.d/01-permitrootlogin.conf
```

```console
# systemctl reload sshd
```

```console
# sshd -T | grep -i permitrootlogin
permitrootlogin no
```

```console
# grep -Ri PermitRootLogin /etc/ssh/sshd_config*
/etc/ssh/sshd_config:PermitRootLogin no
/etc/ssh/sshd_config:# the setting of "PermitRootLogin prohibit-password".
/etc/ssh/sshd_config.bak:#PermitRootLogin prohibit-password
```

```console
$ ssh root@127.0.0.1
root@127.0.0.1's password:
Permission denied, please try again.
root@127.0.0.1's password:
```

### Implementing Key-Based Authentication

```console
# ssh-keygen -t rsa -b 4096
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase for "/root/.ssh/id_rsa" (empty for no passphrase):
```

```console
# ssh-copy-id mike@127.0.0.1
/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
The authenticity of host '127.0.0.1 (127.0.0.1)' can't be established.
ED25519 key fingerprint is SHA256:[example-fingerprint].
```

```console
$ ssh mike@127.0.0.1
mike@127.0.0.1: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

### Using the Default SSH Port

```console
# firewall-cmd --permanent --add-port=2222/tcp
success
```

```console
# firewall-cmd --reload
success
```

```console
# semanage port -a -t ssh_port_t -p tcp 2222
```

```console
$ ssh -p 2222 student@127.0.0.1 *PUT PORT NUMBER LIKE THIS TO CONNECT*
```

```console
# getenforce
Enforcing
```

```console
# sudo semanage port -l | grep ssh
ssh_port_t                     tcp      2222, 22
```

### Configuring Login Attampt Limits

```console
$ ssh -p 2222 student@127.0.0.1
student@127.0.0.1's password:
Permission denied, please try again.
student@127.0.0.1's password:
```

### Testing and Troubleshooting

```console
$ ssh -v -p 2222 student@127.0.0.1
OpenSSH_for_Windows_9.5p2, LibreSSL 3.8.2
debug1: Connecting to 127.0.0.1 [127.0.0.1] port 2222.
debug1: Connection established.
```

```console
$ ssh -vvv -p 2222 student@127.0.0.1
OpenSSH_for_Windows_9.5p2, LibreSSL 3.8.2
debug3: Failed to open file:C:/Users/student/.ssh/config error:2
debug3: Failed to open file:C:/ProgramData/ssh/ssh_config error:2
```

```console
# journalctl -xeu sshd
Oct 11 17:53:27 rhcsa.lab-project.io sshd-session[39962]: Failed password for student from 10>
Oct 11 17:53:29 rhcsa.lab-project.io unix_chkpwd[39973]: password check failed for user (oer>
Oct 11 17:53:31 rhcsa.lab-project.io sshd-session[39962]: Failed password for student from 10>
```

### Using SELinux for Firewall

```console
$ ls -Z ~/.ssh
unconfined_u:object_r:ssh_home_t:s0 id_rsa
unconfined_u:object_r:ssh_home_t:s0 id_rsa.pub
unconfined_u:object_r:ssh_home_t:s0 known_hosts
```

```console
# restorecon -Rv ~/.ssh
restorecon is used to fix selinux context
-R applies it recursively
-v enables the verbose output
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Validate SSH configuration without cutting off access

```bash
sshd -t
sshd -T | grep -E '^(port|permitrootlogin|passwordauthentication|maxauthtries) '
sshd -T -C user=root,host=lab.example,addr=192.0.2.20
systemctl reload sshd
journalctl -u sshd -b --no-pager | tail -n 30
ssh -vvv -p 2222 student@lab.example
```

In my VM, I found conflicting root-login values in drop-in configuration and tested the effective config. `sshd -T` without `-C` is useful, but a connection-specific result may depend on `Match` blocks. A failed login alone doesn't prove every root login route is disabled.

Port 2222 needed a firewalld allowance **and** an SELinux `ssh_port_t` label for sshd to bind it. An alternate port reduces background scanning noise but is not an authentication security boundary. I would keep a working session open and test a fresh second login before disabling passwords or reloading remote SSH. See [root login](../labs/ssh-root-login.md) and [port change](../labs/ssh-port-and-selinux.md).

## Related lab write-ups

- [Ssh root login](../labs/ssh-root-login.md)
- [Ssh key authentication](../labs/ssh-key-authentication.md)
- [Ssh port and selinux](../labs/ssh-port-and-selinux.md)
- [Ssh auth and config tests](../labs/ssh-auth-and-config-tests.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **3: SSH/SCP; 8: Securing SSH**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/security_hardening/index) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
