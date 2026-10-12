# NFS: I mounted the wrong path

I had already configured an NFS share and was mounting it back to the same machine through `127.0.0.1`. I managed to type the wrong path:

```console
# mount -t nfs 127.0.0.1:/nfs/shared ~/nfs_client
mount.nfs: access denied by server while mounting 127.0.0.1:/nfs/shared
```

I checked the export configuration:

```console
# cat /etc/exports
/srv/nfs/share 127.0.0.1(rw,sync,no_root_squash)
```

The exported path was `/srv/nfs/share`, not `/nfs/shared`. Using that path worked:

```console
# mount -t nfs 127.0.0.1:/srv/nfs/share ~/nfs_client
# df -h
```

In this case the error message looked like an access problem, but the immediate mistake was the path. `exportfs -v` and `showmount -e` were useful to compare what the server was exporting with what I was trying to mount.

I tested different mount options afterward, including read-only and timeout/retransmission settings. One of my earlier notes spelled `retrans` as `retarns`; corrected here.

My lab export used `no_root_squash`, and I also experimented with very broad directory permissions. Neither is a safe production default. A loopback test also doesn't verify access from another client on a real network.
