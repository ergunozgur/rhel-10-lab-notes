# 14. Control Services and Daemons

systemd targets, unit files, dependencies, overrides, masking and service logs. I also created a small custom service and timer.

> Original lab notebook: approximately lines 6515–7767. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### Using systemd Services

```console
# sleep 500 &
[2] 14458
[1]   Done                    sleep 300
```

```console
# ps -ef | grep sleep
root       14458    3667  0 12:00 pts/0    00:00:00 sleep 500
root       14482    3667  0 12:01 pts/0    00:00:00 grep --color=auto sleep
```

```console
# pgrep -l sleep
14458 sleep
```

```console
# kill %1
-bash: kill: %1: no such job
```

```console
# kill %2
```

```console
# ps -ef | grep sshd
root        1256       1  0 07:43 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        3627    1256  0 07:43 ?        00:00:00 sshd-session: root [priv]
root        3666    3627  0 07:43 ?        00:00:11 sshd-session: root@pts/0
```

```console
# ps -p 1
PID TTY          TIME CMD
1 ?        00:00:07 systemd
# show only command name
```

```console
# ps -p 2 -o comm=
kthreadd
```

```console
# ps -p 3 -o comm=
pool_workqueue_release
```

```console
# pstree -p
systemd(1)─┬─ModemManager(1190)─┬─{ModemManager}(1209)
│                    ├─{ModemManager}(1214)
│                    └─{ModemManager}(1216)
```

### Managing services

```console
# systemctl status sshd
● sshd.service - OpenSSH server daemon
Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; preset: enabled)
Active: active (running) since Fri 2026-08-28 10:51:27 CEST; 4h 8min ago
```

```console
# systemctl list-units --type=target
```

```console
# systemctl list-units --type=socket
```

### Implementing Service Dependencies

```console
# systemctl list-dependencies --reverse docker
docker.service
● └─multi-user.target
○   └─graphical.target
```

```console
# systemctl list-dependencies --reverse httpd
httpd.service
```

```console
# systemctl cat httpd
# /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.
# Modifying this file in-place is not recommended, because changes
```

```console
# systemctl get-default
multi-user.target
```

### Implementing Masking and Unmasking Services

```console
# sudo systemctl status bluetooth.service
○ bluetooth.service
Loaded: masked (Reason: Unit bluetooth.service is masked.)
Active: inactive (dead)
```

```console
# sudo systemctl unmask bluetooth.service
Removed '/etc/systemd/system/bluetooth.service'.
# start
```

```console
# systemctl status bluetooth.service
○ bluetooth.service - Bluetooth service
Loaded: loaded (/usr/lib/systemd/system/bluetooth.service; enabled; preset: enabled)
Active: inactive (dead)
```

### Reloading vs. Restarting Services

```console
# systemctl start firewalld
```

```console
# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; preset: enabled)
Active: active (running) since Fri 2026-08-28 10:51:26 CEST; 7h ago
```

```console
# systemctl reload firewalld
```

```console
# systemctl show -p CanReload docker
CanReload=yes
```

```console
# systemctl show -p CanReload firewalld
CanReload=yes
```

### Configuring Timers

```console
# cat <<EOF | sudo tee /etc/systemd/system/cleanup.service
> [Unit]
> Description = Clear Temp File
>
```

### user enter to go to new row

```console
# systemctl daemon-reexec
```

```console
# systemctl enable --now cleanup.timer
Created symlink '/etc/systemd/system/timers.target.wants/cleanup.timer' → '/etc/systemd/system/cleanup.timer'.
```

### Configuring Custom Services and Daemons

```console
# sudo tee /usr/local/bin/helloservice.sh<<EOF
> #!/bin/bash
> echo "Hello from my custom service at \$(date) " >> /tmp/hello.log
> EOF
```

```console
# systemctl daemon-reload
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Before editing a unit file

```bash
systemctl status sshd
systemctl cat sshd
systemctl show -p FragmentPath,DropInPaths sshd
systemctl list-dependencies sshd
systemctl list-dependencies --reverse sshd
systemctl --failed
systemd-analyze verify /etc/systemd/system/example.service
```

The unit supplied by a package is not a good place for custom changes because updates can replace it. I prefer `systemctl edit <unit>` for an override, followed by `systemctl daemon-reload` and controlled service verification.

`start` changes the running state; `enable` configures startup at boot; `mask` actively prevents a unit from being started. `Wants=` is a weaker dependency than `Requires=`. `After=` controls ordering, not whether a unit is pulled in. My timer and custom-service exercises are preserved under [labs](../labs/systemd-timer.md).

## Related lab write-ups

- [Systemd timer](../labs/systemd-timer.md)
- [Cron systemd timers](../labs/cron-systemd-timers.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **5: systemd and Boot Process; 9: Administration**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
