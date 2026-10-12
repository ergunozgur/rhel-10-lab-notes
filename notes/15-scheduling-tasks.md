# 15. Scheduling Tasks

User and system cron jobs, at jobs, anacron and systemd timers. The uptime logger is a real example I set up and checked.

> Original lab notebook: approximately lines 7768–8200. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### Using Cron-Periodic Task Scheduler

```console
# crontab -e
no crontab for root - using an empty one
crontab: installing new crontab
```

```console
# crontab -l
30 7 * * * /home/student/backup.sh
```

```console
# crontab -r
Backup of root's previous crontab saved to /root/.cache/crontab/crontab.bak
```

### Implementing User vs System Crontabs

```console
# sudo nano /etc/crontab
```

```console
$ echo $HOME
/root
~ symbol represents home directory /root
```

```console
# chmod +x ~/logtime.sh
```

```console
# ~/logtime.sh
This job ran at Sat Sep  5 08:26:37 PM CEST 2026
```

```console
# cat ~/cron_output.txt
This job ran at Sat Sep  5 08:30:01 PM CEST 2026
This job ran at Sat Sep  5 08:31:01 PM CEST 2026
This job ran at Sat Sep  5 08:32:01 PM CEST 2026
```

```console
# mkdir -p /opt/scripts
```

```console
# sudo nano /opt/scripts/uptime-logger.sh
```

```console
# sudo nano /etc/systemd/system/uptime-logger.service
```

```console
# nano /etc/systemd/system/uptime-logger.timer
```

```console
# systemctl daemon-reexec #gets all newly created services and times
```

```console
# systemctl enable --now uptime-logger.timer
Created symlink '/etc/systemd/system/timers.target.wants/uptime-logger.timer' → '/etc/systemd/system/uptime-logger.timer'.
```

```console
# systemctl list-timers --all
NEXT                             LEFT LAST                               PASSED UNIT       >
Sat 2026-09-05 20:57:09 CEST       7s Sat 2026-09-05 20:56:09 CEST      52s ago uptime-logg>
Sat 2026-09-05 20:58:00 CEST      57s Sat 2026-09-05 20:28:11 CEST    28min ago pmie_check.>
```

```console
# cat /var/log/uptime.log
Uptime Log: Sat Sep  5 08:56:09 PM CEST 2026
20:56:09 up 50 min,  1 user,  load average: 0.63, 0.52, 0.40
```

### configuring job scheduling enviroment variables

```console
# cat ~/test.log
Hello
```

```console
# nano ~/hello.sh
```

```console
# chmod +x ~/hello.sh
```

### using the at command

```console
# sudo dnf install at -y
Updating Subscription Management repositories.
Last metadata expiration check: 20:57:26 ago on Sat 05 Sep 2026 09:39:16 PM CEST.
Package at-3.2.5-14.el10_1.x86_64 is already installed.
```

```console
# sudo systemctl start atd
```

```console
# sudo systemctl enable atd
```

```console
# at now + 5 minute
warning: commands will be executed using /bin/sh
at Sun Sep  6 18:57:00 2026
at> echo "this is a one time task" >> ~/test.log
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### A reminder about cron versus timers

```bash
crontab -l
crontab -e
systemctl list-timers --all
systemctl status crond
journalctl -u crond -b --no-pager
atq
```

Cron runs at the matching wall-clock schedule, but it won't automatically replay every missed user-cron job after downtime. Anacron and systemd timers have different behavior for missed executions. With systemd timers I can use `Persistent=true` for calendar timers when missed activations matter.

For scripts run unattended, absolute paths and a known environment make failures easier to diagnose. `crontab -r` removes the current user's table; check the account before using it. My uptime timer wrote entries at roughly one-minute intervals, recorded in the source notes.

## Related lab write-ups

- [Cron systemd timers](../labs/cron-systemd-timers.md)
- [Systemd timer](../labs/systemd-timer.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **9: cron, at and Bash Scheduling**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
