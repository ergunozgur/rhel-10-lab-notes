# 03. Managing Files

I used this part to work through ownership, wildcards, archives, symlinks and file comparison rather than just memorizing `ls` and `cp`.

> Original lab notebook: approximately lines 574–1061. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### File system basics

```console
$ cd -
/root
```

```console
$ cd ~
```

```console
$ cd Desktop
```

```console
$ cd /var/log
```

```console
$ ls /home/student/test/test?.txt
ls: cannot access '/home/student/test/test?.txt': No such file or directory
```

```console
$ ls file?.txt
file1.txt  file2.txt  file3.txt  file4.txt  file5.txt  file6.txt
```

```console
$ ls file[1-6].txt
file1.txt  file2.txt  file3.txt  file4.txt  file5.txt  file6.txt
```

```console
$ ls -l /etc > etc_list.txt
```

```console
# cat etc_list.txt
total 1324
-rw-r--r--.  1 root                 root                     16 Apr 16 14:31 adjtime
```

```console
# df -h >> disk_report.txt
```

```console
# cat disk_report.txt
Filesystem             Size  Used Avail Use% Mounted on
/dev/mapper/rhel-root   36G  9.0G   27G  26% /
devtmpfs               1.8G     0  1.8G   0% /dev
```

```console
# wc -l < /etc/passwd
42
```

```console
# grep /bin/bash /etc/passwd | cut -d: -f1
root
student
test
```

### Finding and locating files

```console
# type cd
cd is a shell builtin
```

```console
$ ls -l
total 6956
-rw-------. 1 root root     936 Apr 16 14:32 anaconda-ks.cfg
-rw-r--r--. 1 root root 7088950 Jul 10 20:26 backup.tar.gz
```

### performing file content analysis

```console
# cat users.txt
john
john
root
```

```console
# sort users.txt
deamon
demo
demo
```

```console
# sort users.txt | uniq
deamon
demo
dora
```

```console
# diff test.txt test1.txt
1,3c1
< [redacted-data] f hwuefhewh
<
```

Some earlier outputs had long, repetitive directory listings and placeholder test-file names; I kept representative parts, not every byte of the terminal transcript.

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Archives, links and copies

A `.tar` archive is a bundle, **not automatically compression**. The `-z` flag adds gzip compression. A `.tar.gz` extension doesn't make a file gzip-compressed on its own.

```bash
tar -czf config-backup.tar.gz /etc/ssh /etc/chrony.conf
tar -tzf config-backup.tar.gz | head
tar -xzf config-backup.tar.gz -C /tmp/restore-test
sha256sum config-backup.tar.gz
ln -s /etc/ssh/sshd_config ./sshd-link
stat ./sshd-link
readlink -f ./sshd-link
```

I can use `find -type f -size +100M` to locate large files and `du -xh --max-depth=1 /var` to find disk-hungry directories. For a backup I want to test restore, not just see a successful archive command. `rsync -a --dry-run source/ destination/` is a useful preview when comparing two directory trees.

## Related lab write-ups

- [Busy mount](../labs/busy-mount.md)
- [Backup script and log format](../labs/backup-script-and-log-format.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **2: File and Directory Concepts; 9: Archives**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/managing_file_systems/mounting-file-systems) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
