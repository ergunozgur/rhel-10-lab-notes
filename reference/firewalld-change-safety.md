# Firewalld: interface, zone, service, port and persistence

I added and removed services and TCP ports in the VM and tested richer rules. The main thing I want to remember is that opening a port in the **wrong zone** won't help, and a runtime rule may not survive a reload.

```bash
sudo firewall-cmd --state
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --list-all
sudo firewall-cmd --list-all --permanent
sudo firewall-cmd --get-zone-of-interface=<interface>
```

If access is failing, confirm the destination service is listening and whether any upstream firewall or routing device is in the way. `firewall-cmd` rules are a local host control, not a replacement for networking diagnostics.

A typical change flow, with `<...>` replaced only after checking the right zone and service:

```bash
sudo firewall-cmd --zone=<zone> --add-service=<service>
sudo firewall-cmd --zone=<zone> --list-all
# Persist *only after* confirming it works:
sudo firewall-cmd --runtime-to-permanent
```

Alternatively, a permanent change can be created with `--permanent` and applied with `--reload`. Reloading can also discard runtime-only changes. For SSH and network administration, keeping an existing session and a recovery path is essential.

Special cases: rich rules have precedence and matching semantics; forwarding and masquerading don't automatically mean the host is securely configured as a router. I would record the intended source subnet, destination and protocol before adding them.

For NFS, remember that allowing only the `nfs` service can be sufficient for an NFSv4-only arrangement, while legacy NFSv3-related services need additional consideration. Avoid casually opening RPC services to untrusted networks.
