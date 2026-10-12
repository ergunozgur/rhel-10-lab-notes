# 20. Access Control Lists (ACLs)

Extended ACLs, effective permissions, masks and defaults. The mask behavior and recursive tests were the most useful part.

> Original lab notebook: approximately lines 11141–11803. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### Creating a test filesystem

```console
# fdisk /dev/sdb
Welcome to fdisk (util-linux 2.40.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.
```

```console
# mkfs.ext4 /dev/sdb
mke2fs 1.47.1 (20-May-2024)
Found a dos partition table in /dev/sdb
Proceed anyway? (y,N) y
```

### create a mount point for new partition

```console
# mount /dev/sdb /mnt/acltest/
```

```console
# systemctl daemon-reload
```

```console
# mount -o remount,acl /mnt/acltest/
```

### Configuring and Managing ACLs

```console
$ cd /mnt/acltest/
```

```console
$ echo "this is a test file" > file1.txt
```

```console
# cat file1.txt
this is a test file
```

```console
# setfacl -m u:useracl:r-- file1.txt
setfacl - sets file permissions using acls
m - tells the system to modify the acl
u:useracl:r-- - means give a user named useracl read-only access
```

```console
# getfacl -R /mnt/acltest
getfacl: Removing leading '/' from absolute path names
# file: mnt/acltest
# owner: root
```

### Removing ACLs

```console
# setfacl -m u:useracl:rw- file1.txt
```

```console
# setfacl -x u:useracl file1.txt
```

### ACL mask permissions

```console
$ echo "bu ne olum" > file2.txt
```

```console
$ echo "bu nedd olum" > file2.txt
```

```console
# getfacl file2.txt
# file: file2.txt
# owner: root
# group: root
```

```console
# setfacl -m u:useracl:rwx file2.txt
```

### Configuring Default ACLs for Directories

```console
$ ls -l
total 32
-rw-r--r--+ 1 root root    20 Oct 11 14:38 file1.txt
-rw-r--r--+ 1 root root    27 Oct 11 14:58 file2.txt
```

```console
# touch file.txt
```

```console
# setfacl -d -m u:useracl:rx file.txt
setfacl: file.txt: Only directories can have default ACLs
```

```console
$ ls -ld default
drwxr-xr-x. 2 root root 4096 Oct 11 15:12 default
```

```console
# setfacl -d -m u:useracl:rx /mnt/acltest/default/
```

```console
# setfacl -d -m u:useracl:r /mnt/acltest/default/
```

```console
$ ls -l /mnt/acltest/default/
total 0
```

```console
# getfacl test.txt /mnt/acltest/default/
# file: test.txt
# owner: root
# group: root
```

### Implementing Recursive ACL Changes

```console
# mkdir -p /mnt/acltest/demo/docs
```

```console
# setfacl -R -m u:useracl:rw /mnt/acltest/
```

```console
# getfacl demo/file2.txt
# file: demo/file2.txt
# owner: root
# group: root
```

**About my filesystem experiment:** the source notes include a `mkfs.ext4 /dev/sdb` operation despite an existing `/dev/sdb1` partition. Formatting the whole disk instead of the intended partition is potentially destructive. These recorded commands are history from a disposable VM, not a recommended ACL setup recipe. Ext4 and XFS generally support POSIX ACLs without needing a separate filesystem just for ACL tests.

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### ACL mask versus apparent permissions

```bash
getfacl /srv/project
setfacl -m u:student:rwx /srv/project
getfacl /srv/project
setfacl -m m::r-- /srv/project
getfacl /srv/project
```

The `mask` is an upper bound for named-user entries, named-group entries and the owning group entry. A line showing `user:student:rwx` does **not** mean the user has all three effective permissions if the mask is `r--`. `getfacl` displays effective permissions when they differ.

`setfacl -d -m u:student:rwX /srv/project` sets a default ACL on a directory for newly created children, but **`-R` on an existing directory tree is not the same thing as inheriting defaults for future files**. In my notebook I explored both; not every attempted check proved the inheritance case. ACLs don't remove the need to check directory traversal permissions.

## Related lab write-ups

- [Acl mask and defaults](../labs/acl-mask-and-defaults.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **2: File Permissions; 7: Filesystem Administration**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/managing_file_systems/mounting-file-systems) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
