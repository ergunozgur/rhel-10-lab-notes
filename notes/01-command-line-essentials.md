# 01. Command Line Essentials

This is where I started getting comfortable with the RHEL shell: moving around the filesystem, inspecting services, users, and how a machine boots.

> Original lab notebook: approximately lines 1–245. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

```console
$ echo $SHELL
/bin/bash
```

```console
# gnome-shell --version
GNOME Shell 47.8
```

### Changing directories

```console
$ cd /etc
```

### Reading file permissions

```console
$ ls -l
total 24
-rw-r--r--. 1 student student 17052 Apr 16 14:58 6afedf8f.txt
drwxr-xr-x. 2 student student     6 Apr 16 14:33 Desktop
```

### Changing file ownership

```console
# chown john:john test1.txt
chown: invalid user: ‘john:john’
```

### Directories and navigation

```console
$ cd Desktop
```

```console
$ ls -la
total 4
drwxr-xr-x.  2 student student    6 Apr 16 14:33 .
drwx------. 17 student student 4096 Jul 10 20:25 ..
```

```console
$ cd ..
```

```console
$ cd test1
```

```console
# sudo touch test.txt
```

```console
$ echo "Hello John"
Hello John
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Boot sequence I want to remember

The rough flow is **firmware → GRUB → kernel/initramfs → systemd (PID 1) → login**. The initramfs loads what the kernel needs to find and mount the root filesystem; it does not start all normal system services. I originally mixed those two jobs up.

```bash
cat /etc/os-release
uname -r
hostnamectl
systemctl get-default
systemd-analyze blame       # Inspect slow boot units; not a reason to disable them blindly
journalctl -b -p warning
```

For remote work I prefer a non-root account with `sudo` instead of logging in directly as root. `sudo -l` is a quick way to see what the current account may execute. The GRUB rescue experiment is described separately under [root recovery](../labs/grub-and-root-recovery-notes.md).

## Related lab write-ups

- [Grub and root recovery notes](../labs/grub-and-root-recovery-notes.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **2: Fundamental Command-Line Skills; 5: Boot Process**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
