# 12. Accessing Network File Systems (NFS)

NFS client/server setup on loopback, exports, mount options, service dependencies and firewall rules. It included a wrong-path mount error.

> Original lab notebook: approximately lines 5336–5944. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### Accessing Network File Systems (NFS)

```console
# sudo dnf install nfs-utils
Updating Subscription Management repositories.
Docker CE Stable - x86_64                                383  B/s | 2.0 kB     00:05
Red Hat Enterprise Linux 10 for x86_64 - BaseOS (RPMs)   693  B/s | 4.1 kB     00:05
```

```console
# sudo systemctl enable --now rpcbind
Created symlink '/etc/systemd/system/multi-user.target.wants/rpcbind.service' → '/usr/lib/systemd/system/rpcbind.service'.
```

### implementing NFS shares discovery

```console
# yum install showmount
Updating Subscription Management repositories.
Last metadata expiration check: 0:37:16 ago on Wed 12 Aug 2026 08:09:21 PM CEST.
Package nfs-utils-1:2.8.3-5.el10_2.x86_64 is already installed.
```

```console
# showmount -e localhost
Export list for localhost:
/srv/nfs/share 127.0.0.1
```

```console
# sudo chown -R student:student /srv/nfs/share
chown change ownership
```

```console
$ echo "hi this is nfs server" | sudo tee /srv/nfs/share/test.txt
hi this is nfs server
```

```console
# cat /srv/nfs/share/test.txt
hi this is nfs server
```

```console
# sudo exportfs -v
/srv/nfs/share  127.0.0.1(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
```

```console
# sudo exportfs -r
```

```console
# sudo systemctl enable --now nfs-server
```

### steps of temp mounting

```console
# df -hT
Filesystem            Type      Size  Used Avail Use% Mounted on
/dev/mapper/rhel-root xfs        36G   11G   25G  31% /
devtmpfs              devtmpfs  1.8G     0  1.8G   0% /dev
```

### using commands for mount options

```console
# sudo mount -t nfs 127.0.0.1:/nfs/shared ~/nfs_client
mount.nfs: access denied by server while mounting 127.0.0.1:/nfs/shared
```

```console
# sudo mount -t nfs 127.0.0.1:/srv/nfs/share ~/nfs_client
```

```console
# sudo mount -t nfs -o soft,timeo=100,retrans=3 127.0.0.1:/srv/nfs/share
~/nfs_client
```

### mount nfs share in read only mode

```console
# sudo mount -t nfs -o ro 127.0.0.1:/srv/nfs/share ~/nfs_client
```

```console
# mount | grep nfs
nfsd on /proc/fs/nfsd type nfsd (rw,relatime)
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw,relatime)
```

```console
# sudo umount 127.0.0.1:/srv/nfs/share
```

### forcefully unmount the file system

```console
# sudo umount -f ~/nfs_client
```

### check active zone

```console
# sudo firewall-cmd --get-active-zones
public (default)
interfaces: enp0s3
```

```console
# sudo firewall-cmd --list-all
public (default, active)
target: default
ingress-priority: 0
```

```console
# sudo firewall-cmd --reload
success
```

### we have to enable 2 additional services required by nfs

```console
# sudo firewall-cmd --permanent --add-service=mountd
success
```

```console
# sudo firewall-cmd --permanent --remove-service=rpc-bind
success
```

### check the status of the nfs client service

```console
# systemctl status rpcbind
● rpcbind.service - RPC Bind
Loaded: loaded (/usr/lib/systemd/system/rpcbind.service; enabled; preset: disabled)
Active: active (running) since Tue 2026-08-25 14:50:20 CEST; 34min ago
```

```console
# sudo systemctl enable --now nfs-client.target
if the service is already active, the command will produce no output
```

### lets check whether the nfs related kernel modules are loaded

```console
# lsmod | grep nfs
nfsv4                1376256  0
dns_resolver           16384  1 nfsv4
nfs                   720896  1 nfsv4
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### For an NFS mount that refuses to cooperate

```bash
exportfs -v
showmount -e 127.0.0.1
systemctl status nfs-server
findmnt -t nfs,nfs4
nfsstat -m
journalctl -u nfs-server -b --no-pager
```

Start by checking the exported directory path, whether the client is allowed to access it, and whether the server actually exported the share. One of my own failures was simply mounting the wrong path.

NFSv4 and NFSv3 don't have identical service/port requirements; `rpcbind` and `mountd` are particularly relevant for older NFS setups. Don't open services just because an example did. For important writable shares, `soft` mounts can lead to application I/O errors; mount choices depend on workload, and `hard` is commonly the safer data-integrity default.

For less frequently accessed shares the RHEL guide also discusses `autofs` on-demand mounts. That's additional reference material, not something inferred from my loopback test.

## Related lab write-ups

- [Nfs wrong path](../labs/nfs-wrong-path.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **7: Filesystem Management and Automounter**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/managing_file_systems/mounting-nfs-shares) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
