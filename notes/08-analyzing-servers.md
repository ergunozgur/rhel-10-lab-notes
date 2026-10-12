# 08. Analyzing Servers

Checking CPU, memory, disk, I/O and collecting support data. This section is about diagnosing first, rather than applying random tuning settings.

> Original lab notebook: approximately lines 2297–2894. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### analyzing servers

```console
# uptime
10:41:30 up 2 min,  1 user,  load average: 0.28, 0.31, 0.13
```

```console
# top
top - 10:43:03 up 4 min,  1 user,  load average: 0.08, 0.23, 0.12
Tasks: 241 total,   1 running, 240 sleeping,   0 stopped,   0 zombie
%Cpu(s):  2.9 us,  8.6 sy,  0.0 ni, 77.1 id,  2.9 wa,  8.6 hi,  0.0 si,  0.0 st
```

```console
# dnf install sysstat -y
```

```console
# mpstat -P ALL
Linux 6.12.0-211.39.1.el10_2.x86_64 (lab.example)     07/28/2026      _x86_64_        (3 CPU)
10:48:13 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
10:48:13 AM  all    1.00    0.04    1.99    0.59    3.11    0.41    0.00    0.00    0.00   92.87
```

```console
# ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head
PID    PPID CMD                         %MEM %CPU
6416    3391 ps -eo pid,ppid,cmd,%mem,%c  0.1  300
1274       1 /usr/bin/containerd          1.5  3.0
```

### using commands to analyze memory RAM

```console
# cat /proc/meminfo
```

```console
# ps aux --sort=%mem | head -10
```

### check diskspace usage by directory

```console
# du -sh /var/*
0       /var/account
0       /var/adm
222M    /var/cache
```

### check io status

```console
# iostat -xz 1 5
-x shows extended stattistics for each Device
-z omits(skips) devices with no activity
1 updates the output every 1 second
```

### block-level io stats

```console
# cat /sys/block/sda/stat
mount | column -t ##displays all currently mounted file systems
```

```console
# mount | column -t
sysfs                  on  /sys
#mount displays all currently mounted file systems
```

### check the status of a specific service

```console
# systemctl list-units --type=service
UNIT                                     LOAD   ACTIVE   SUB     JOB   DESCRIPTION
accounts-daemon.service                  loaded active   running       Accounts Service
atd.service                              loaded active   running       Deferred execution scheduler
```

```console
# systemctl list-units --type=target
```

### view details about a specific target

```console
# systemctl status multi-user.target
● multi-user.target - Multi-User System
Loaded: loaded (/usr/lib/systemd/system/multi-user.target; static)
Active: active since Wed 2026-07-29 21:35:57 CEST; 23min ago
```

### if you suspect the sshd process is consuming too many resource

```console
# pgrep sshd
1280
1923
4404
```

```console
# kill 4886
-bash: kill: (4886) - No such process
```

```console
# kill -9 4886
-bash: kill: (4886) - No such process
```

### using commands to detect blocks

```console
# ausearch -m avc -c nginx
<no matches>
or sshd or httpd
```

```console
# sealert -a /var/log/audit/audit.log
100% done
found 0 alerts in /var/log/audit/audit.log
```

### verifing and repairing packages

```console
# rpm -Va
```

```console
# rpm -V httpd
```

```console
# rpm -V sshd
package sshd is not installed
```

### compare installed files with those provided by the httpd packa

```console
# rpm -ql httpd
/etc/httpd/conf.modules.d/00-brotli.conf
/etc/httpd/conf.modules.d/00-systemd.conf
/usr/lib/.build-id
```

```console
# rpm -qc httpd
/etc/httpd/conf.modules.d/00-brotli.conf
/etc/httpd/conf.modules.d/00-systemd.conf
```

### generate command in non-interactive mode

```console
# sos report --batch
does it right away without asking
```

```console
# sudo sos report --only-plugins network,system
sos report (version 4.11.0)
a non-existing plugin (network) was specified in the command line.
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Fast checks before touching tuning settings

```bash
uptime
free -h
vmstat 1 5
iostat -xz 1 5
ps -eo pid,user,%cpu,%mem,cmd --sort=-%cpu | head
findmnt -T /
df -hT
journalctl -b -p err --no-pager
sos report --batch
```

Load average needs context (CPU count, runnable and uninterruptible tasks); a high value alone doesn't tell me whether CPU is saturated. If `%iowait` is high, I look at the affected disks and processes. Swap usage alone is not a crash indicator either.

A `sos report` can package log files, configuration and possibly sensitive data. I would inspect the archive before sharing it with support. Changing I/O scheduler or swappiness should follow measurement and a clear goal, not a generic performance-tip article.

## Related lab write-ups

- [Process priority and monitoring](../labs/process-priority-and-monitoring.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **9: Resource Management and System Tuning**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
