# 09. Storage and Logical Volume Management (LVM)

Extra VirtualBox disks, partitions, PV/VG/LV operations, formatting, mounting and expansion. I kept the small XFS-volume failure and the resize sequence.

> Original lab notebook: approximately lines 2895–3760. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

```console
# pvs
PV         VG   Fmt  Attr PSize   PFree
/dev/sda3  rhel lvm2 a--  <39.63g    0
```

```console
# vgs
VG   #PV #LV #SN Attr   VSize   VFree
rhel   1   2   0 wz--n- <39.63g    0
```

```console
# lvs
LV   VG   Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
root rhel -wi-ao---- 35.68g
swap rhel -wi-ao---- <3.95g
```

### Creating a partition on the lab disk

```console
# lsblk
NAME          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda             8:0    0 40.6G  0 disk
├─sda1          8:1    0    1M  0 part
```

```console
# fdisk /dev/sdb
Welcome to fdisk (util-linux 2.40.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.
```

### configuring physical volume creation

```console
# fdisk -l
Disk /dev/sdb: 1 GiB, 1073741824 bytes, 2097152 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
```

```console
# sudo pvdisplay
--- Physical volume ---
PV Name               /dev/sda3
VG Name               rhel
```

### Removing an experimental PV

```console
# sudo pvremove /dev/sdb1
Labels on physical volume "/dev/sdb1" successfully wiped.
```

```console
# sudo lvmdiskscan
/dev/sdb1 [     500.00 MiB]
/dev/sda3 [      39.63 GiB] LVM physical volume
0 disks
```

### implementing creation of volume groups

```console
# sudo pvcreate /dev/sdb1
Physical volume "/dev/sdb1" successfully created.
```

### create volume group

```console
# vgcreate myvg /dev/sdb1
Volume group "myvg" successfully created
```

```console
# sudo vgs
VG   #PV #LV #SN Attr   VSize   VFree
myvg   1   0   0 wz--n- 496.00m 496.00m
rhel   1   2   0 wz--n- <39.63g      0
```

```console
# sudo vgdisplay
--- Volume group ---
VG Name               rhel
System ID
```

```console
# sudo vgremove myvg
Volume group "myvg" successfully removed
```

### using commands for creating logical volumes

```console
# sudo lvs
LV   VG   Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
root rhel -wi-ao---- 35.68g
swap rhel -wi-ao---- <3.95g
```

```console
# sudo lvcreate -L 5M -n mylv myvg
Rounding up size to full physical extent 8.00 MiB
Logical volume "mylv" created.
```

```console
# sudo lvdisplay /dev/myvg/mylv
--- Logical volume ---
LV Path                /dev/myvg/mylv
LV Name                mylv
```

```console
# sudo lvdisplay
--- Logical volume ---
LV Path                /dev/rhel/swap
LV Name                swap
```

### format it using mkfs

```console
# sudo mkfs.ext4 /dev/myvg/mylv
mke2fs 1.47.1 (20-May-2024)
Creating filesystem with 8192 1k blocks and 2048 inodes
Allocating group tables: done
```

```console
# sudo mkdir /mnt/mylv
```

```console
$ ls /mnt
mylv  rhel
```

```console
$ cd /mnt/mylv/
```

```console
# sudo mount /dev/myvg/mylv /mnt/mylv
```

### check the available free space within the volume group

```console
# sudo lvextend -L +200M /dev/myvg/mylv
Size of logical volume myvg/mylv changed from 8.00 MiB (2 extents) to 208.00 MiB (52 extents).
Logical volume myvg/mylv successfully resized.
```

```console
# sudo lvextend -l +100%FREE /dev/myvg/mylv
Size of logical volume myvg/mylv changed from 208.00 MiB (52 extents) to 496.00 MiB (124 extents).
Logical volume myvg/mylv successfully resized.
```

```console
# sudo resize2fs /dev/myvg/mylv
resize2fs 1.47.1 (20-May-2024)
Please run 'e2fsck -f /dev/myvg/mylv' first.
```

```console
# e2fsck -f /dev/
Display all 172 possibilities? (y or n)
```

```console
# e2fsck -f /dev/myvg/mylv
e2fsck 1.47.1 (20-May-2024)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
```

### configuring for removing LVM

```console
# mount | grep mylv
```

```console
# sudo umount /mnt/mylv
umount: /mnt/mylv: not mounted.
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Grow the right layer

First I identify the device and mount, then confirm free extents in the volume group. **Growing the LV and growing the filesystem are related but separate operations.**

```bash
lsblk -f
pvs
vgs
lvs -a -o +devices
findmnt -T /mnt/data
# Example on a disposable ext4 LV, only after identifying the correct device:
lvextend -L +1G /dev/myvg/mylv
resize2fs /dev/myvg/mylv
# Combined operation when supported:
lvextend -r -L +1G /dev/myvg/mylv
```

For XFS the filesystem is grown with `xfs_growfs <mountpoint>` while mounted; XFS doesn't support shrinking in the usual way. For ext4, `resize2fs` is the corresponding tool; filesystem-check procedures differ depending on whether it is mounted. I wouldn't use `e2fsck` on a live mounted writable filesystem.

If `mkfs.xfs` rejects a tiny volume, that's an actual minimum-size issue, not a permission problem. I ran into this on my 8 MiB test LV. See the [LVM lab](../labs/lvm-xfs-size.md).

## Related lab write-ups

- [Lvm xfs size](../labs/lvm-xfs-size.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **7: Storage and Filesystem Administration**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/managing_storage_devices/disk-partitions) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
