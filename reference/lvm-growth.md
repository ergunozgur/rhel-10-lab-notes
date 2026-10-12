# Extending an LVM volume without forgetting the filesystem

In my VM I created a physical volume, a volume group and a logical volume. I grew the LV and learned that the filesystem did not become larger automatically. I also tried an XFS filesystem on an 8 MiB LV and discovered it was too small.

## First establish the layout

```bash
lsblk -f
findmnt /mountpoint
pvs
vgs
lvs -a -o +devices
df -hT /mountpoint
```

Before an extension on an important machine, confirm backup and recovery options, free capacity in the volume group, the intended LV, the mounted filesystem type and the maintenance impact. Device naming can change, so don't copy `/dev/sdb` from someone else's example.

## Two layers need to grow

When LVM has enough free extents, Red Hat supports extending the logical volume and growing supported filesystems together. Example only:

```bash
sudo lvextend -r -L +5G /dev/vg_data/lv_data
```

`-r` requests a filesystem resize as part of the operation. Without it, the LV size and the filesystem size can diverge. For manual growth, XFS is typically grown **while mounted** with `xfs_growfs /mountpoint`; ext4 growth uses `resize2fs` on the correct block device, with its online/offline constraints. Check both sizes afterward.

**Important:** RHEL's XFS cannot be shrunk. ext4 shrinking is an offline task requiring extra precautions and a filesystem check. Don't use an ext4 repair/resize recipe on XFS.

For a newly attached physical disk, partitioning and PV initialization are destructive to existing data; use a separate build plan. A grow request should never begin by formatting an ambiguous device.

Docs: [Red Hat logical volumes](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html-single/configuring_and_managing_logical_volumes/index) and [file systems](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html-single/managing_file_systems/index).
