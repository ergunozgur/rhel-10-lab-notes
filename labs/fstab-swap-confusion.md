# `/etc/fstab`: I mixed up XFS and swap during the storage exercises

I used the same extra VirtualBox disk for several different labs. At one point `/dev/sdb1` was an XFS filesystem mounted at `/home`, and `/dev/sdb2` had been used as swap. My later notes suggested putting this into `/etc/fstab`:

```fstab
/dev/sdb1 none swap defaults 0 0
```

The problem is that the `blkid` output I recorded for `sdb1` showed **`TYPE="xfs"`**, not swap. Copying that entry into a real `/etc/fstab` would be wrong and could cause mount/boot problems. The UUID in the note also belonged to XFS, so changing `/dev/sdb1` to `UUID=...` did not fix the underlying issue.

A safer way to approach any persistent mount or swap entry:

```bash
lsblk -f
blkid
findmnt --verify
swapon --show
```

Check the *current* device type and UUID instead of reusing one from a previous lab run. For a new **already initialized** swap partition, the pattern is `UUID=<actual-swap-uuid> none swap defaults 0 0`. Verify the swap UUID with `blkid` **after** running `mkswap` on the intended disposable partition.

This lab made me realize why keeping an evolving scratchpad is tricky: yesterday's disk layout can become today's incorrect instruction. I later removed stale `fstab` lines before continuing. I haven't included a universal edit command because the correct devices depend on the machine.
