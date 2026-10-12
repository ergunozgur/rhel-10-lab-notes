# 18. Firewalls

firewalld zones, services, ports and temporary versus persistent rules. It is easy to lose access by treating the wrong zone as active.

> Original lab notebook: approximately lines 9714–10510. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### firewalld commands

```console
# sudo systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; preset: enabled)
Active: active (running) since Thu 2026-10-08 12:05:26 CEST; 1h 39min ago
```

### firewall zones

```console
# sudo firewall-cmd --get-active-zones
docker
interfaces: docker0
public (default)
```

```console
# sudo firewall-cmd --list-all
public (default, active)
target: default
ingress-priority: 0
```

### start firewalld

```console
# sudo firewall-cmd --get-default-zone
public
```

```console
# sudo firewall-cmd --zone=public --list-all
public (default, active)
target: default
ingress-priority: 0
```

```console
# sudo firewall-cmd --zone=internal --list-all
internal
target: default
ingress-priority: 0
```

### add services temporarily or permanently

```console
# sudo firewall-cmd --zone=internal --add-service=nfs
success
```

```console
# sudo firewall-cmd --reload
success
```

```console
# sudo firewall-cmd --zone=internal --permanent --add-service=nfs
success
```

```console
# sudo firewall-cmd --zone=internal --remove-service=nfs --permanent
success
```

### open tcp 8081 in public zone

```console
# sudo firewall-cmd --zone=public --add-port=8081/tcp
success
```

```console
# sudo firewall-cmd --permanent --zone=public --add-port=8081/tcp
success
```

```console
# sudo firewall-cmd --zone=public --permanent --remove-port=8081/tcp
success
```

### display firewall rules configured in public zone

```console
# sudo firewall-cmd --list-all --zone=public
public (default, active)
target: default
ingress-priority: 0
```

```console
# sudo firewall-cmd --zone=public --remove-port=8080/tcp
success
```

```console
# sudo firewall-cmd --runtime-to-permanent
success
```

```console
# sudo firewall-cmd --list-rich-rules
```

```console
# sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="8.8.8.8" service name="ssh" accept'
success
```

```console
# sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="8.8.8.8" icmp-type name="echo-request" accept'
success
```

### change zone assignment of a network interface

```console
# sudo firewall-cmd --get-zone-of-interface=enp0s3
public
```

```console
# sudo firewall-cmd --zone=trusted --change-interface=enp0s3
success
```

```console
# sudo firewall-cmd --permanent --zone=trusted --change-interface=enp0s3
The interface is under control of NetworkManager, setting zone to 'trusted'.
success
```

```console
# sudo firewall-cmd --zone=trusted --list-all
trusted (active)
target: ACCEPT
ingress-priority: 0
```

```console
# sudo firewall-cmd --permanent --zone=public --change-interface=enp0s3
The interface is under control of NetworkManager, setting zone to 'public'.
success
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### What I check before opening a port

```bash
firewall-cmd --state
firewall-cmd --get-active-zones
firewall-cmd --zone=public --list-all
firewall-cmd --zone=public --list-all --permanent
firewall-cmd --get-services
ss -lntup
```

Open services only in the **zone attached to the correct interface/connection**. Runtime rules can be tested before permanent rules. `--reload` recreates runtime settings from the permanent configuration, so a temporary exception may disappear.

Moving everything into `trusted` is not a troubleshooting solution; it accepts all network connections in that zone. When adjusting firewalld over SSH I keep an independent working session and a way back if I change the wrong zone. See the [firewall lab](../labs/firewalld-temporary-permanent.md).

## Related lab write-ups

- [Firewalld temporary permanent](../labs/firewalld-temporary-permanent.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **8: Basic Firewall Control**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/configuring_firewalls_and_packet_filters/using-and-configuring-firewalld) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
