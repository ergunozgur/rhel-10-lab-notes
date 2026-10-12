# 07. Analyzing and Storing Logs

I practised journald, rsyslog, log rotation, persistent journals and forwarding. Logs are usually the first place I go when a service behaves unexpectedly.

> Original lab notebook: approximately lines 1935–2296. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### implementing log file locations

```console
$ cd /var/log
```

```console
$ ls -lh
```

```console
# tail -f /var/log/messages
-f means follow and it will show live information until you close it
```

```console
# tail /var/log/cron
```

### using journalctl

```console
# journalctl -u sshd
-u --unit=UNIT #Show logs from the specified unit
-p --priority=RANGE#Show entries within the specified priority r>
```

```console
# journalctl -p err
```

```console
# journalctl -b -1
Specifying boot ID or boot offset has no effect, no persistent journal was found.
```

```console
# journalctl -b -p err -u sshd
-b #shows log from current boot
-p err #filter logs to only show log entries marked as error
-u sshd #narrows it down to sshd service
```

### implementing log rotation and management

```console
# cat /etc/logrotate.conf
# see "man logrotate" for details
# global options do not affect preceding include directives
# rotate log files weekly
```

```console
# logrotate -f /etc/logrotate.conf## manual rotate of logs
```

### custom rotation conf

```console
# nano /etc/logrotate.d/custom.log
```

```console
$ cd /etc/logrotate.d/
```

```console
# logrotate -f /etc/logrotate.d/customlog
-f # force
```

### configuring persistent journal storage

```console
$ ls -ld /run/log/journal
drwxr-sr-x+ 3 root systemd-journal 60 Jul 27 13:01 /run/log/journal
```

```console
# mkdir -p /var/log/journal
-p is making sure any missing parent directories getting created
```

```console
# sudo journalctl --disk-usage
Archived and active journals take up 40M in the file system.
```

```console
$ ls -ld /run/log/journal/
drwxr-sr-x+ 3 root systemd-journal 60 Jul 27 13:01 /run/log/journal/
```

```console
$ ls -la /run/log/journal/
total 0
drwxr-sr-x+ 3 root systemd-journal  60 Jul 27 13:01 .
drwxr-xr-x. 3 root root             60 Jul 27 13:01 ..
```

### configuring forwarding logs

```console
# systemctl status rsyslog
● rsyslog.service - System Logging Service
Loaded: loaded (/usr/lib/systemd/system/rsyslog.service; enabled; preset: enabled)
Active: active (running) since Mon 2026-07-27 13:02:27 CEST; 9h ago
```

```console
# systemctl restart rsyslog
```

### we need to allow udp port 514 through the firewall

```console
# firewall-cmd --list-all
public (default, active)
target: default
ingress-priority: 0
```

```console
# firewall-cmd --reload
success
```

### extra#### to disable localrepo because i didnt had the iso fil

```console
# dnf clean all
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### When I need evidence of a failed service

```bash
systemctl --failed
journalctl -b -p warning --no-pager
journalctl -u sshd --since '30 minutes ago' --no-pager
journalctl -k -b --no-pager | tail -n 50
journalctl --disk-usage
logger -t lab-check 'log pipeline test'
```

`rsyslog` can write and forward messages, while `systemd-journald` collects structured journal entries. Log rotation controls file growth; retention and journal persistence are separate choices.

Before configuring remote log forwarding I would verify the receiver, network, transport and format. My original notes show the sender-side config and firewall change, not proof that a remote collector stored a message. I have not changed that outcome in the [rsyslog lab](../labs/rsyslog-forwarding-notes.md).

On a real system I'd also avoid forwarding sensitive authentication logs to an untrusted plain UDP destination.

## Related lab write-ups

- [Rsyslog forwarding notes](../labs/rsyslog-forwarding-notes.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **9: Local Log Files**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
