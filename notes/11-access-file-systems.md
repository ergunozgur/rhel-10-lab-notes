# 11. Access File Systems

Block devices, UUIDs, mounts, XFS versus ext4, swap, quotas and `/etc/fstab`. Several operations were on a disposable virtual disk.

> Original lab notebook: approximately lines 4268–5335. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### implementing file system access commands

```console
# blkid
/dev/mapper/rhel-swap: UUID="41b0b4ad-8369-486f-89c0-16e357d47952" TYPE="swap"
/dev/sdb1: PARTUUID="a53765cd-01"
/dev/mapper/rhel-root: UUID="5f0f05c2-29b1-4cfd-b662-66c6a86b0126" BLOCK_SIZE="512" TYPE="xfs"
```

```console
# lsblk
NAME          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda             8:0    0 40.6G  0 disk
├─sda1          8:1    0    1M  0 part
```

### reformat sdb1 with xfs

```console
# mkfs.xfs -f /dev/sdb1
meta-data=/dev/sdb1              isize=512    agcount=4, agsize=32000 blks
=                       sectsz=512   attr=2, projid32bit=1
=                       crc=1        finobt=1, sparse=1, rmapbt=1
```

```console
# fsck /dev/sdb1
fsck from util-linux 2.40.2
If you wish to check the consistency of an XFS filesystem or
repair a damaged filesystem, see xfs_repair(8).
```

```console
# xfs_repair -L /dev/sdb1
Phase 1 - find and verify superblock...
Phase 2 - using internal log
```

```console
# e2fsck -f /dev/sdb1
e2fsck 1.47.1 (20-May-2024)
ext2fs_open2: Bad magic number in super-block
e2fsck: Superblock invalid, trying backup blocks...
```

### lets install required NFS utilities

```console
# sudo dnf install nfs-utils -y
```

### lets create a directory to share via NFS

```console
$ echo "Acccesed via NFS locally" | sudo tee /srv/nfs/share/info.txt
Acccesed via NFS locally
```

### lets give full permissions to our shared directory

```console
# chmod -R 777 /srv/nfs/share
chmod changes permissions
-R applies changes recursively
777 gives read,write and execute permissions to everyone
```

### lets add entry to the NFS exports file

```console
$ echo "/srv/nfs/share 127.0.0.1(rw,sync,no_root_squash)" | sudo tee -a /etc/exports
/srv/nfs/share 127.0.0.1(rw,sync,no_root_squash)
```

```console
# sudo exportfs -r
exportfs manages nfs exports
-r rereads the /etc/exports file and applies the changes
```

### lets make the NFS client entry

```console
# sudo mount -t nfs 127.0.0.1:/srv/nfs/share ~/nfs-client
```

```console
$ cd ~/nfs-client
```

```console
# showmount -e 127.0.0.1
Export list for 127.0.0.1:
/srv/nfs/share 127.0.0.1
```

```console
# mount | grep nfs
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw,relatime)
nfsd on /proc/fs/nfsd type nfsd (rw,relatime)
```

### lets create new partition for swap

```console
# fdisk /dev/sdb
Welcome to fdisk (util-linux 2.40.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.
```

```console
# swapon /dev/sdb2
```

```console
# swapon --show
NAME      TYPE      SIZE USED PRIO
/dev/dm-1 partition 3.9G   0B   -2
/dev/sdb2 partition 523M   0B   -3
```

```console
# free -h
total        used        free      shared  buff/cache   available
Mem:           3.6Gi       712Mi       2.5Gi       1.0Mi       656Mi       2.9Gi
Swap:          4.5Gi          0B       4.5Gi
```

```console
# sudo mount /home
```

```console
# findmnt /home
TARGET SOURCE    FSTYPE OPTIONS
/home  /dev/sdb1 xfs    rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,usrquota
```

```console
# sudo mount -o remount /home
```

```console
$ cd /home
```

```console
# sudo xfs_quota -x -c 'limit bsoft=300M bhard=400M ethan' /home
x enables export mode
c specifies the quota command to run
limit bsoft=300M bhard=400M ethan - limit
```

### verify the quota

```console
# sudo xfs_quota -x -c 'report -u' /home
User quota on /home (/dev/sdb1)
Blocks
User ID          Used       Soft       Hard    Warn/Grace
```

### revertback whats done on previous labs (clear sdb )

```console
# umount /home
umount: /home: target is busy.
```

```console
# lsof +D /home
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
bash    14121 root  cwd    DIR   8,17       19  128 /home
vim     15417 root  cwd    DIR   8,17       19  128 /home
```

```console
# pwd echo $$
/root
```

```console
# kill 14121 15417
```

```console
# kill -9 14121 15417
```

```console
# vim etc
```

```console
# vim /etc/fstab
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### A mount checklist

```bash
lsblk -f
blkid
findmnt
findmnt --verify
findmnt -T /var
mount -a
swapon --show
```

In `/etc/fstab`, the **device/UUID, mount point and filesystem type must agree**. A UUID identifying an XFS filesystem cannot be reused as though it were swap. I made a confusing swap/XFS entry in the original notebook, and the [fstab lab](../labs/fstab-swap-confusion.md) explains the issue.

If I mount a new filesystem on a populated directory, the old files are hidden until I unmount it; they're not automatically deleted. Mounting directly over `/home` on a running machine can break active sessions.

XFS repair is `xfs_repair` on an unmounted filesystem, not `e2fsck`. Its `-L` option may discard pending metadata log transactions, so it belongs at the end of a recovery process, not at the beginning.

## Related lab write-ups

- [Xfs versus ext4](../labs/xfs-versus-ext4.md)
- [Fstab swap confusion](../labs/fstab-swap-confusion.md)
- [Xfs quota on test home](../labs/xfs-quota-on-test-home.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **7: Filesystem Administration and Automounter**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/managing_file_systems/mounting-file-systems) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
