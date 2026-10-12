# 16. User and Group Management

Creating users and groups, sudo/wheel, password aging, locked accounts, defaults and `/etc/skel`. This section includes the administration tests.

> Original lab notebook: approximately lines 8201–9022. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### Managing User Accounts

```console
# sudo passwd demo
New password:
Retype new password:
passwd: password updated successfully
```

```console
# sudo useradd -u 2025 -g demogroup demorhel
-u 2025 sets user id to 2025
-g assigns group name - demogroup to the user demorhel
```

```console
# sudo usermod -aG wheel demo
```

```console
# sudo usermod -d /demo -m demo
usermod: directory /demo exists
```

```console
# grep demo /etc/passwd
demo:x:1003:1003::/demo:/bin/bash
demorhel:x:2025:1004::/home/demorhel:/bin/bash
```

```console
# grep demorhel /etc/passwd
```

```console
# sudo useradd demorhel
```

```console
# lastlog | grep demorhel
demorhel                                                            **Never logged in**
```

### Managing Password Configuration

```console
# passwd demo
New password:
Retype new password:
passwd: password updated successfully
```

```console
# chage -l demo
Last password change                                    : password must be changed
Password expires                                        : password must be changed
Password inactive                                       : password must be changed
```

```console
# chage -m 5 -M 20 demo
+ -m minimum number of days
```

```console
# chage -d 0 demo
```

### Managing Groups

```console
# grep developers /etc/group
developers:x:1006:
```

```console
# grep devteam /etc/group
devteam:x:1006:
```

```console
# sudo usermod -g devteam demo
```

### Configuring Default Settings

```console
$ ls -la /etc/skel
total 24
drwxr-xr-x.   3 root root   78 Apr 16 14:25 .
drwxr-xr-x. 147 root root 8192 Oct  7 14:03 ..
```

```console
$ echo "Welcome User" | sudo tee /etc/skel/welcome.txt
Welcome User
```

```console
# sudo passwd student
New password:
Retype new password:
passwd: password updated successfully
```

```console
# cat /home/student/welcome.txt
Welcome User
```

```console
# cat /etc/login.defs | grep -i home
#   home directory.  If you _do_ define both, MAIL_DIR takes precedence.
# hushed mode will be enabled if the file exists in the user's home directory.
# home directories if HOME_MODE is not set.
```

### root@localhost:/# id admin

```console
# sudo passwd admin
New password:
Retype new password:
passwd: password updated successfully
```

### Allow root to run any commands anywhere

```console
# su - admin
```

### Same thing without a password

```console
# sudo usermod -aG wheel student
```

```console
# su - student
Last login: Wed Aug 26 10:58:56 CEST 2026 from 192.0.2.20 on pts/1
```

### Switching User Accounts

```console
# su -
Password:
Last login: Wed Oct  7 13:19:02 CEST 2026 from 192.0.2.20 on pts/0
```

```console
# sudo -u admin whoami
admin
```

### lock and unlock user accounts

```console
# sudo passwd intern
New password:
Retype new password:
passwd: password updated successfully
```

```console
# sudo passwd -l intern
passwd: password changed.
```

```console
# sudo passwd -S intern
intern L 2026-10-07 0 99999 7 -1
L locked
last password change date
```

```console
# sudo passwd -S student
student P never 0 99999 7 -1
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Account checks before a permission change

```bash
id student
groups student
getent passwd student
getent group wheel
passwd -S student
chage -l student
sudo -l
visudo -c
last -n 10
```

`/etc/passwd` has account metadata, whereas password hashes and password-aging fields belong to `/etc/shadow` (which should never be published in raw form). `useradd`, `usermod` and `userdel` affect different things; removing an account doesn't always remove leftover files with that numeric UID. `usermod -aG wheel student` appends a supplementary group without dropping existing group memberships.

Password lock (`passwd -l`) and account expiry (`chage -E`) solve different problems. Never interpret one option as proof that every possible authentication path has been blocked. I explored `/etc/skel` and login defaults in the same section.

## Related lab write-ups

- [User account and password aging](../labs/user-account-and-password-aging.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **6: User Administration**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/security_hardening/index) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
