# 04. Help Commands and Text Editing

Finding documentation without a browser, editing from a terminal and learning how much easier it is to investigate commands before using them.

> Original lab notebook: approximately lines 1062–1296. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### configuring log monitoring

```console
$ ls /var/log
anaconda           chrony           hawkey.log           messages-20260719  spooler-20260719
audit              cron             hawkey.log-20260710  private            sssd
boot.log           cron-20260710    hawkey.log-20260719  qemu-ga            tuned
```

```console
# tail -f /var/log/messages
Jul 23 18:53:59 localhost systemd[1]: NetworkManager-dispatcher.service: Deactivated successfully.
Jul 23 18:54:00 localhost systemd[1]: systemd-localed.service: Deactivated successfully.
Jul 23 18:54:00 localhost NetworkManager[1086]: <info>  [1784825640.7910] policy: set-hostname: set hostname to 'lab.example' (no hostname found)
```

```console
# tail -f /var/log/messages | grep failed
```

```console
# tail -f /var/log/messages | grep -i failed
```

```console
# tail -f /var/log/secure | grep sshd
Jul 23 18:53:18 localhost sshd-session[3605]: Connection reset by user student 192.0.2.20 port 50076
Jul 23 18:53:19 localhost sshd-session[3570]: pam_systemd(sshd:session): Failed to release session: Remote peer disconnected
Jul 23 18:53:19 localhost sshd-session[3570]: pam_unix(sshd:session): session closed for user student
```

```console
# systemctl restart firew
alld ## this is split terminal
```

```console
# tail -f /var/log/messages | grep firewall
Jul 23 18:59:26 localhost systemd[1]: Stopping firewalld.service - firewalld - dynamic firewall daemon...
Jul 23 18:59:27 localhost systemd[1]: firewalld.service: Deactivated successfully.
Jul 23 18:59:27 localhost systemd[1]: Stopped firewalld.service - firewalld - dynamic firewall daemon.
```

### using nano for text files

```console
# ./hello.sh
Hello Ozgur
```

### using wim as text editor.

```console
# vim backup.sh
```

```console
# chmod +x backup.sh
```

```console
# ./backup.sh
tar: Removing leading `/' from member names
Backup complete
```

### Using gedit for editing text files (graphical text editor)

```console
# sudo dnf install gedit -y
Updating Subscription Management repositories.
Last metadata expiration check: 3:52:23 ago on Thu 23 Jul 2026 05:28:39 PM CEST.
No match for argument: gedit
```

```console
# dnf repolist
Updating Subscription Management repositories.
repo id                                  repo name
docker-ce-stable                         Docker CE Stable - x86_64
```

```console
# dnf search gedit
Updating Subscription Management repositories.
Last metadata expiration check: 3:54:23 ago on Thu 23 Jul 2026 05:28:39 PM CEST.
========================================== Name Matched: gedit ==========================================
```

```console
# sudo dnf install gnome-text-editor -y
Updating Subscription Management repositories.
Last metadata expiration check: 3:55:34 ago on Thu 23 Jul 2026 05:28:39 PM CEST.
Package gnome-text-editor-47.4-2.el10.x86_64 is already installed.
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Where I look before searching online

```bash
man sshd_config
man 5 fstab
man -k 'logical volume'
command -v semanage
rpm -qf /usr/bin/systemctl
ls /usr/share/doc/
systemctl cat sshd
```

The man page number matters: section 5 often documents file formats while section 8 usually documents administration utilities. `type` also distinguishes shell built-ins from external commands.

In my lab the old `gedit` package wasn't available, and launching a GUI editor as root over an SSH-only terminal produced `Failed to open display`. I used the terminal editors instead; the failure was about GUI/display availability, not missing root rights. See the [editor lab](../labs/gnome-text-editor.md).

## Related lab write-ups

- [Gnome text editor](../labs/gnome-text-editor.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **2: Accessing Documentation; Managing Text Files**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
