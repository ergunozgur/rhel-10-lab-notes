# 13. Process Monitoring and Management

Processes, PIDs, foreground/background jobs, signals, process trees and nice values. A working knowledge of these commands saves time during incidents.

> Original lab notebook: approximately lines 5945–6514. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### Configuring Process Monitoring

```console
# ps -u student
PID TTY          TIME CMD
```

```console
# ps -t pts/0
PID TTY          TIME CMD
4667 pts/0    00:00:00 bash
20081 pts/0    00:00:00 ps
```

```console
# ps -ef --forest
UID          PID    PPID  C STIME TTY          TIME CMD
root           2       0  0 14:49 ?        00:00:00 [kthreadd]
root           3       2  0 14:49 ?        00:00:00  \_ [pool_workqueue_release]
```

### find the process id of hhtpd

```console
# pgrep httpd
```

```console
# pgrep nfs
1081
1705
1706
```

```console
# pgrep -u root
1
2
3
```

### active sessions

```console
# w
11:02:36 up 9 min,  2 users,  load average: 0.01, 0.13, 0.14
USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT
root               10:53    9:18   0.00s  0.12s sshd-session: root [priv]
```

### pidof to find pid

```console
# systemctl status httpd
● httpd.service - The Apache HTTP Server
Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; preset: disabled)
Active: active (running) since Wed 2026-08-26 11:06:55 CEST; 4s ago
```

```console
# pidof httpd
5103 5087 5060 5059 5058
```

### use pstree to view the process tree

```console
# pstree 5103
httpd───52*[{httpd}]
```

```console
# pstree -u student
No processes found.
```

```console
# pstree -u root
systemd─┬─ModemManager───3*[{ModemManager}]
├─NetworkManager───3*[{NetworkManager}]
├─VBoxDRMClient───4*[{VBoxDRMClient}]
```

```console
# pstree $(pgrep -n httpd)
httpd───52*[{httpd}]
```

### Implementing and Managing Background Process

```console
# sleep 100 &
[1] 7347
```

```console
# fg %1
-bash: fg: job has terminated
[1]+  Done                    sleep 100
```

### press ctrl+z

```console
# ps aux | grep sleep
root        7586  0.0  0.0 226836  2024 pts/0    S    12:01   0:00 sleep 100
root        7588  0.0  0.0 227704  2136 pts/0    S+   12:01   0:00 grep --color=auto sleep
```

```console
# kill 7586
[1]+  Terminated              sleep 100
```

```console
# kill -9 7586
-bash: kill: (7586) - No such process
```

### Configuring Processes Priorities and Scheduling

```console
# sleep 300 &
[1] 7027
```

```console
# ps -eo pid,comm,ni,pri,etime,args | grep sleep
7027 sleep             0  19       01:30 sleep 300
7030 grep              0  19       00:00 grep --color=auto sleep
```

```console
# tar: Removing leading `/' from member names
^C
[1]+  Done                    nice -n 10 tar -czf backup.tar.gz /var/log
```

```console
# nice -n -5 sleep 200 &
[1] 7832
```

```console
# sudo renice -10 8052
8052 (process ID) old priority 0, new priority -10
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### When a process seems stuck

```bash
ps -ef --forest | head -n 30
pgrep -a sshd
ps -o pid,ppid,stat,ni,%cpu,%mem,cmd -p 1234
pstree -p 1 | head -n 40
lsof -p 1234 | head
kill -TERM 1234
# SIGKILL only if normal termination failed and the consequences are understood
kill -KILL 1234
```

A zombie has exited but hasn't been reaped by its parent; signaling the zombie itself doesn't solve the underlying parent problem. A `D` state usually indicates uninterruptible wait and cannot always be cleared by SIGKILL. Nice values influence CPU scheduling priority; smaller nice values typically mean higher priority, and root privileges are needed to increase priority. I practised both `nice` and `renice`.

## Related lab write-ups

- [Process priority and monitoring](../labs/process-priority-and-monitoring.md)
- [Busy mount](../labs/busy-mount.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **9: System Tuning and Resource Management**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
