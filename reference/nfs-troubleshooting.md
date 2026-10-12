# NFS access: is it the export, the path, the client, or the network?

My initial NFS mistake was simple: I mounted `/nfs/shared` even though `/etc/exports` listed `/srv/nfs/share`. The client error looked like an access denial, so I initially focused on the wrong layer.

## Server checks

```bash
systemctl status nfs-server
sudo exportfs -v
cat /etc/exports
sudo ss -lntp | grep ':2049'
```

Make sure the **exported server path** is correct, the filesystem is mounted, the client is allowed by the export rule, and the service actually listens. An existing path on the client has no bearing on which path the server exports.

## Client checks

```bash
getent hosts <nfs-server>
findmnt /mnt/nfs-share
mount -t nfs -o vers=4.2 <nfs-server>:/srv/nfs/share /mnt/nfs-share
nfsstat -m
```

`showmount -e` can help with exports on servers supporting the relevant RPC/mountd services, but it isn't a definitive test for every NFSv4-only setup. Check the actual NFS version and export model.

My local lab used loopback (`127.0.0.1`) and at one stage `no_root_squash` and permissive directory modes. Those settings are not a sensible network-facing default. For a real server I would plan client restrictions, ownership, `root_squash`, the required security flavor and firewall scope.

NFS `soft` mounts can return errors during an outage, which might be appropriate for some workloads and dangerous for data-integrity-sensitive writes. Don't blindly copy my timeout experiments into production. Check application requirements first.
