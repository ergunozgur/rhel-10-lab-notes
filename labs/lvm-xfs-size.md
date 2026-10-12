# LVM: XFS wouldn't format my tiny logical volume

I attached a separate virtual disk to the RHEL VM and went through the `pvcreate` → `vgcreate` → `lvcreate` sequence. I called the volume group `myvg` and the logical volume `mylv`.

My first LV was tiny. LVM rounded the requested size up to **8 MiB**. When I tried formatting it as XFS:

```console
# mkfs.xfs /dev/myvg/mylv
size 2048 of data subvolume is too small, minimum 4096 blocks
```

Rather than trying to force XFS onto that tiny volume, I formatted it as ext4 for the next part of the exercise:

```console
# mkfs.ext4 /dev/myvg/mylv
# mkdir /mnt/mylv
# mount /dev/myvg/mylv /mnt/mylv
```

I then practised extending the LV, first by 200 MiB, then with all the space remaining in the VG:

```console
# lvextend -L +200M /dev/myvg/mylv
# lvextend -l +100%FREE /dev/myvg/mylv
```

The LV reached **496 MiB**, but the filesystem didn't grow simply because the LV had become bigger. My first `resize2fs` attempt asked me to run `e2fsck` first. My notes show `e2fsck` followed by a successful `resize2fs`, but they do **not** show a nearby `umount` command, so I cannot confirm the mount state at that moment. On a real machine, `e2fsck` must only be used against an **unmounted ext4** filesystem.

```console
# e2fsck -f /dev/myvg/mylv
# resize2fs /dev/myvg/mylv
```

I came away with a distinction worth remembering: **logical volume size and filesystem size are separate**. `lvextend -r` can grow both when the filesystem supports it. Disk and filesystem operations here were done on a disposable lab drive.
