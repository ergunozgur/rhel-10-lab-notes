# 17. Linux Networking

NetworkManager, static addressing, DNS, routes and socket inspection. My goal was to understand the active connection before changing it.

> Original lab notebook: approximately lines 9023–9713. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### show connections using nmcli

```console
# nmcli connection show
NAME     UUID                                  TYPE      DEVICE
enp0s3   aa06f003-5c34-3d11-a752-ea5fb3e5e1a2  ethernet  enp0s3
lo       1a99fd93-3c6f-4264-a967-134179d95285  loopback  lo
```

### dhcp or dynamic addressing

```console
# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
inet 127.0.0.1/8 scope host lo
```

### check the network status

```console
# nmcli device status
DEVICE   TYPE      STATE                   CONNECTION
enp0s3   ethernet  connected               enp0s3
lo       loopback  connected (externally)  lo
```

### show active connections

```console
# nmcli con show --active
NAME     UUID                                  TYPE      DEVICE
enp0s3   aa06f003-5c34-3d11-a752-ea5fb3e5e1a2  ethernet  enp0s3
lo       1a99fd93-3c6f-4264-a967-134179d95285  loopback  lo
```

```console
# nmcli con show
NAME     UUID                                  TYPE      DEVICE
enp0s3   aa06f003-5c34-3d11-a752-ea5fb3e5e1a2  ethernet  enp0s3
lo       1a99fd93-3c6f-4264-a967-134179d95285  loopback  lo
```

```console
# nmcli device show enp0s3
GENERAL.DEVICE:                         enp0s3
GENERAL.TYPE:                           ethernet
GENERAL.HWADDR:                         08:00:27:1F:92:60
```

```console
# ping -c 4 google.com
PING google.com (142.251.20.102) 56(84) bytes of data.
64 bytes from bx-in-f102.1e100.net (142.251.20.102): icmp_seq=1 ttl=64 time=66.1 ms
64 bytes from bx-in-f102.1e100.net (142.251.20.102): icmp_seq=2 ttl=64 time=43.6 ms
```

```console
# sudo dnf install traceroute -y
Updating Subscription Management repositories.
...
Installed:
```

```console
# traceroute google.com
traceroute to google.com (142.251.14.100), 30 hops max, 60 byte packets
1  _gateway (192.0.2.20)  1.517 ms  2.092 ms  1.355 ms
2  * * *
```

### check dns resolution

```console
# host google.com
google.com has address 142.251.20.139
google.com has address 142.251.20.113
google.com has address 142.251.20.102
```

```console
# host lab-project.io
lab-project.io has address 188.114.97.3
lab-project.io has address 188.114.96.3
lab-project.io mail is handled by 10 eforward1.registrar-servers.com.
```

```console
# host 1.1.1.1
1.1.1.1.in-addr.arpa domain name pointer one.one.one.one.
```

### dig command for advanced dns queries

```console
# sudo dnf install bind-utils -y
Updating Subscription Management repositories.
...
Upgraded:
```

```console
# dig google.com
; <<>> DiG 9.18.33 <<>> google.com
;; global options: +cmd
;; Got answer:
```

### set a static hostname

```console
# hostnamectl set-hostname rhcsa.lab-project.io
```

```console
# cat /etc/hostname
rhcsa.lab-project.io
```

### view open ports and services using ss command

```console
# ss -tuln
Netid     State      Recv-Q     Send-Q         Local Address:Port            Peer Address:Port
udp       UNCONN     0          0                  127.0.0.1:323                  0.0.0.0:*
udp       UNCONN     0          0                  127.0.0.1:915                  0.0.0.0:*
```

### view open ports and services using netstat command

```console
# sudo dnf install net-tools -y
[sudo] password for student:
Updating Subscription Management repositories.
Last metadata expiration check: 14:53:54 ago on Wed 07 Oct 2026 09:41:47 PM CEST.
```

```console
# netstat -tulnp
(No info could be read for "-p": geteuid()=1000 but you should be root.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
```

```console
# ss -tulnp | grep 22
tcp   LISTEN 0      128          0.0.0.0:22         0.0.0.0:*
tcp   LISTEN 0      128             [::]:22            [::]:*
```

### use telnet to perform a port test

```console
# sudo dnf install telnet -y
Updating Subscription Management repositories.
...
Installed:
```

```console
# telnet google.com 80
Trying 142.251.14.139...
Connected to google.com.
Escape character is '^]'.
```

### perform a connectivity test using netcat command

```console
# sudo dnf install nmap-ncat -y
Updating Subscription Management repositories.
Last metadata expiration check: 15:02:53 ago on Wed 07 Oct 2026 09:41:47 PM CEST.
Package nmap-ncat-4:7.92-5.el10.x86_64 is already installed.
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Follow the packet path

```bash
ip -br address
ip route
ip rule
nmcli device status
nmcli connection show --active
resolvectl status
getent hosts example.com
ss -lntup
tracepath example.com
```

A connection profile and a network interface are not the same object in NetworkManager. Before changing a static address remotely I need to know which active profile and default route provide my SSH access. `nmcli device reapply` may work for some changes, but not every setting can be changed without reconnecting.

For an IPv4 static example, `nmcli connection modify <profile> ipv4.addresses 192.0.2.20/24 ipv4.gateway 192.0.2.1 ipv4.method manual` changes the profile; activating/reapplying it is a separate step and can disconnect remote access. These addresses are documentation placeholders.

## Related lab write-ups

- [Networkmanager static address](../labs/networkmanager-static-address.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **3: Managing Basic Networking**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html-single/configuring_and_managing_networking/index) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
