# 06. Shell Scripting

My first Bash exercises used variables, conditions, exit codes, logging and debugging. Some early scripts had mistakes; those corrections belong in the notes.

> Original lab notebook: approximately lines 1698–1934. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### shell scripting

```console
# nano check-internet.sh
```

```console
# ./check-internet.sh
Internet is working.
```

```console
# chmod +x firstscript.sh
```

```console
# ./firstscript.sh
Hello this is my first shell in RHEL
```

### bash can be used to call the script

```console
# bash check-internet.sh
Internet is working.
```

### working with variables

```console
# nano variables.sh
```

```console
# bash variables.sh
Hello my name is RHEL User and I am 28 years old.
```

### Bash conditions

```console
# nano ifbasic.sh
```

```console
# chmod +x ifbasic.sh
```

```console
# nano teststatement.sh
```

```console
# ./teststatement.sh
Enter your number:10
10 is equal to 10
```

```console
# chmod +x if_elif.sh
```

```console
# ./if_elif.sh
Disk usage is under control.
#!/bin/bash
usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
```

### Testing Bash scripts

```console
# chmod +x debug.sh
```

```console
# nano debug1.sh
```

```console
# chmod +x debug1.sh
```

### -o makes pipelines fail if any command in them fails

```console
$ cd /tmp/test/
```

### Logging script output with timestamps

```console
# nano script.sh
```

```console
# ./script.sh
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Safer scripting habits

My first scripts used `$?` after `ping`. Once a command runs, `$?` is replaced by that command's status, so checking it late can inspect the wrong thing. I prefer conditions directly around the command.

```bash
#!/usr/bin/env bash
set -euo pipefail
if ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
    printf '%s\n' 'ICMP reachable'
else
    printf '%s\n' 'No ICMP response'
fi
```

Other commands I use while checking scripts:

```bash
bash -n ./script.sh         # Syntax only, doesn't run the script
bash -x ./script.sh         # Traces execution; may expose secrets in output
shellcheck ./script.sh      # If ShellCheck is installed
```

`set -e` is not a replacement for explicit error handling and can behave differently inside conditions. Variables should normally be quoted (`"$variable"`). The original disk-usage exercise had a missing `$` in an `elif`, corrected in the [script example](../scripts/disk-usage-check.sh).

## Related lab write-ups

- [Bash disk condition](../labs/bash-disk-condition.md)
- [Backup script and log format](../labs/backup-script-and-log-format.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **9: Bash Scripts**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
