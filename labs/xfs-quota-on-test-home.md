# XFS quota lab: why mounting over `/home` was a bad habit

I had a disposable XFS partition and mounted it at `/home` to practise user quotas. The mount options showed `usrquota`; I created a test user and applied a soft and hard space limit with `xfs_quota`.

```console
# xfs_quota -x -c 'limit bsoft=300M bhard=400M ethan' /home
# xfs_quota -x -c 'report -u' /home
User quota on /home (...)
...
ethan       12     307200     409600 ...
```

The quota report reflected the limits, so the configuration part worked. But I didn't fill the user's quota to prove how the soft limit, grace time and hard limit behaved under pressure.

I also learned an unrelated but important lesson: mounting an experimental partition over `/home` hides the directory's original contents for as long as it's mounted. It's a poor choice for a learning exercise on a normal system. A safer disposable mount point would be `/mnt/quota-lab`.

When I repeat this, I want to write test files as the restricted user, watch the limits and grace period, then unmount and clean up without touching a real home filesystem.
