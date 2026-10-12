# Filesystem repair: `e2fsck` wasn't the right tool

I had an XFS partition on a test disk and tried comparing the filesystem repair commands.

When I ran `fsck` against the XFS partition, it directed me to `xfs_repair`. Trying `e2fsck -f` on the same partition gave an error and ended with:

```console
/dev/sdb1 contains a xfs file system
```

The problem wasn't a mysteriously broken superblock. I was using an ext-family tool against an XFS filesystem.

Checks to do *before* choosing a repair command:

```bash
lsblk -f
blkid /dev/sdb1
findmnt /dev/sdb1
```

For an **unmounted XFS filesystem** I can inspect with:

```bash
xfs_repair -n /dev/sdb1
```

For an **unmounted ext4 filesystem**, `e2fsck` is the relevant utility instead. I also experimented with `xfs_repair -L` in the VM. That's a last-resort option because it can discard pending log transactions, so it shouldn't be suggested as an ordinary repair step.
