# 19. File Permissions and Ownership

Traditional permissions, ownership, umask, special permission bits and access checks. I kept the experiments that showed the effective outcome.

> Original lab notebook: approximately lines 10511–11140. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### breaking down file permissions with ls- l

```console
$ ls -l
total 6948
-rw-r--r--. 1 student student   17052 Apr 16 14:58 6afedf8f.txt
-rw-r--r--. 1 student student 7088950 Jul 10 20:25 backup.tar.gz
```

### Configuring Default Permissions

```console
$ cd LABTEST/
```

```console
# touch testfile
```

```console
# mkdir testdir2
```

```console
# mkdir demo
```

```console
# source ~/.bashrc
```

### Configuring Access Permission

```console
# chmod u+x test.txt
```

```console
# chmod u-x test.txt
```

```console
# chmod o+x test.txt
```

```console
# chmod 644 demo
drw-r--r--. 2 root root 6 Oct  9 13:31 demo
first 6 means read + write   4+2 for user/owner  ## drw-
4 means only read 4 for group  ## r--
```

### Modifying File Ownership

```console
# touch test.txt
```

```console
# chown student:student test.txt
```

```console
# chgrp root test.txt
```

```console
# chown student test
```

```console
# chown student:admin test
```

```console
# chgrp root test
```

### Using Special File Permissions

```console
$ ls -la /usr/bin | grep passwd
-rwsr-xr-x.  1 root root          78000 Feb 23  2026 gpasswd
-rwxr-xr-x.  1 root root         150208 Mar 27  2026 grub2-mkpasswd-pbkdf2
-rwxr-xr-x.  1 root root          28064 Jul  9 02:00 htpasswd
```

```console
$ ls -la | grep passwd
-rwxr-xr-x.  1 root   root    91424 Oct 10 18:07 passwd-suid
```

```console
# mkdir /shared
```

```console
# useradd user1
```

```console
# groupadd sharedgroup
```

```console
$ ls -l /shared
total 0
* this means there are currently no files inside the directory
```

```console
# usermod -aG sharedgroup user1
```

```console
# su - user1 -c "touch /shared/file1.txt"
touch: cannot touch '/shared/file1.txt': Permission denied
```

```console
# chown root:sharedgroup /shared
```

```console
$ ls -ld /shared
drwxrwsr-x. 2 root sharedgroup 23 Oct 10 18:38 /shared
rws
***** ls -ld only shows the pointed directory properties ***
```

```console
$ ls -ld /test
drwxr-xr-x. 2 root root 6 Jul 10 20:35 /test
```

```console
# su - user2 -c "rm -f /shared/file1.txt"
rm: cannot remove '/shared/file1.txt': Operation not permitted
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Permissions beyond `chmod 755`

```bash
stat -c '%a %U:%G %n' /etc/ssh/sshd_config
namei -l /home/student/project/file.txt
find /srv -type f -perm /002 -print
getfacl /srv/project
umask
```

Directory `x` lets a user traverse known names; it does not mean the same thing as executing a regular file. Setgid on a shared directory is useful for group ownership of new files, while the sticky bit on a shared writable directory limits who can delete entries.

A special bit does not override the rest of the security model: DAC, ACLs and SELinux may all affect access. Avoid solving a permissions error with `chmod -R 777`; inspect each directory component, account groups, ACL mask and SELinux denial first.

## Related lab write-ups

- [Acl mask and defaults](../labs/acl-mask-and-defaults.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **2: File Permissions; 6: Special Groups**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/security_hardening/index) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
