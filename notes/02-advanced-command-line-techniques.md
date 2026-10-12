# 02. Advanced Command Line Techniques

History shortcuts, pipes, redirection, globs, searching and quick text processing. Mostly small commands that become useful when troubleshooting.

> Original lab notebook: approximately lines 246–573. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### cut -d: -f1,3 /etc/passwd - username and ids

```console
# df -h | awk '{print $1, $5}'
Filesystem Use%
/dev/mapper/rhel-root 25%
devtmpfs 0%
```

### sed command for stream editing

```console
# sed -n '1,5p' /etc/passwd
root:x:0:0:Super User:/root:/bin/bash
bin:x:1:1:bin:/bin:/usr/sbin/nologin
daemon:x:2:2:daemon:/sbin:/usr/sbin/nologin
```

### wc -- word counter or counts number of lines

```console
# wc /etc/passwd
42  100 2492 /etc/passwd
```

### implementing search and filter commands

```console
# grep root /etc/passwd
root:x:0:0:Super User:/root:/bin/bash
operator:x:11:0:operator:/root:/usr/sbin/nologin
```

```console
# grep Failed /var/log/secure
```

```console
# grep error /var/log/secure
```

```console
# find /etc -name sshd_config
/etc/ssh/sshd_config
-- Locate command
```

```console
# locate lab-project
/home/student/lab-project
/home/student/lab-project/.dockerignore
/home/student/lab-project/.env
```

```console
# which systemctl
/bin/systemctl
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### A command-line workflow that scales

Pipes and filters save time on a system with huge logs. `grep` is good for simple text; `awk` is useful for fields; `sed` is handy when I need to print or transform selected lines.

```bash
find /etc -type f -name '*.conf' 2>/dev/null | sort
journalctl -u sshd -b --no-pager | tail -n 30
ip -br address
ss -lntup
awk -F: '{print $1, $3}' /etc/passwd
sed -n '20,45p' /etc/ssh/sshd_config
```

`&&` executes the second command only if the first succeeds; `;` executes it regardless. `>` replaces a file and `>>` appends. I always inspect a path before using a wildcard with `rm`.

Bash history can contain secrets entered as arguments, so I don't treat it as a safe place for passwords or access tokens.

## Related lab write-ups

- [Backup script and log format](../labs/backup-script-and-log-format.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **2: Standard Command-Line Tools**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
