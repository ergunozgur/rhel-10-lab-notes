# `/home` was busy when I tried to unmount it

During the disk and partition exercises I temporarily mounted a test XFS partition at `/home`. Later I wanted to undo that setup and couldn't unmount it:

```console
# umount /home
umount: /home: target is busy.
```

I checked what was using that mount:

```console
# findmnt /home
# fuser -vm /home
# lsof +D /home
```

`fuser` and `lsof` identified a shell and a text editor still working inside the mounted directory. In the disposable lab I terminated the processes holding the mount and then unmounted it successfully. On a real system, I would first ask users to leave the directory or close their applications, rather than force-killing processes.

This is a better first check than randomly forcing an unmount. It also made me think more carefully about **where** I mount a throwaway filesystem: `/home` is a poor choice for an experiment on a normal multi-user machine.

I also cleaned up the matching `/etc/fstab` entry before returning to the next storage lab. My original notes included several experimental partition mappings, so I won't reproduce those as a universal recipe.
