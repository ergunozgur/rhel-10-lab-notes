# Network troubleshooting: avoid changing everything at once

My networking notes include `nmcli`, interfaces, routes, DNS queries and port checks. For later incidents I want a simple order of operations so I don't spend an hour debugging SSH when the interface has no address.

## Start at the host

```bash
ip -br address
ip route
nmcli device status
nmcli connection show --active
ip -s link
```

Check whether the expected device is up, has the intended subnet, and has a plausible gateway. If NetworkManager owns the device, prefer changing its **connection profile**, not editing a random file that NetworkManager will later overwrite.

## Work outward

```bash
ping -c 2 <known-gateway>
ping -c 2 1.1.1.1
getent hosts example.com
dig example.com
ss -lntup
curl -I --max-time 10 https://example.com
```

An ICMP reply is different from DNS resolution. DNS resolution is different from TCP reachability. A locally listening port is different from an application responding to a remote client. A firewall on the server, an upstream device, or SELinux may still affect the path.

If connecting to a remote port, `nc -vz <host> <port>` gives a fast transport-level check when netcat is installed, but still doesn't prove the application protocol is healthy.

## Before changing a remote IP

Capture the current `nmcli connection show <profile>` and `ip route` output, keep console access, and prepare rollback. A typo in a static gateway can remove the SSH connection used to repair it. On cloud images, check whether `cloud-init` or a management system will overwrite local networking changes on reboot.

Docs: [RHEL 10 NetworkManager](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html-single/configuring_and_managing_networking/index).
