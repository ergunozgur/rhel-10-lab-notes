# VirtualBox networking and SSH

This was one of the confusing parts of my setup: **an SSH connection to the VM depends on both the VM's network mode and the SSH server inside RHEL**. Those are two different layers.

## Choosing the network mode

| Mode | What to expect |
|---|---|
| **NAT** | Guest usually has outbound connectivity; direct inbound connections need a port-forwarding rule |
| **Bridged** | Guest appears on the same network as the host; access depends on the LAN and firewall |
| **Host-only** | Good for a host-to-guest lab network, usually without direct external internet access |
| **NAT Network** | Multiple VMs can communicate on the same NAT network and use configured forwarding |

I wouldn't use Bridged just because SSH feels easier: it potentially makes a test service reachable from other devices on the LAN. For experiments, NAT with a port-forward rule restricted to loopback is often enough.

## Example: host SSH to an NAT guest

**New reference example, not a transcript from my earlier lab:** Assume the guest's SSH server still listens on port `22`. In VirtualBox, forward **host `127.0.0.1:2222`** to **guest port `22`**.

Through the VirtualBox UI, find the VM's network adapter settings, choose NAT and add a port-forwarding rule. An equivalent host-side command on supported VirtualBox versions is:

```bash
VBoxManage modifyvm "RHEL-Lab" --nat-pf1 "ssh,tcp,127.0.0.1,2222,,22"
```

Replace `RHEL-Lab` with your VM name. Run `VBoxManage` on the **host**, not inside RHEL. With that rule, connect from the host:

```bash
ssh -p 2222 labuser@127.0.0.1
```

Here, **2222 is a host-side forwarding port**, not the SSH service port inside the VM. I also practised changing the **RHEL sshd port to 2222** in a separate lab, which required firewalld and an SELinux SSH port label. Those cases are different: [SSH port and SELinux lab](../labs/ssh-port-and-selinux.md).

## Check the guest before changing settings

```bash
ip -br address
ip route
nmcli device status
sudo systemctl status sshd
sudo ss -tlnp | grep sshd
sudo sshd -t
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --list-services
```

These help distinguish a down service, an interface without an address, a closed firewall zone and an actual SSH configuration error. `sshd -t` checks syntax, but by itself it doesn't prove users can authenticate or connect over the network.

If I need to troubleshoot further:

```bash
sudo journalctl -u sshd -b --no-pager | tail -n 50
ssh -v -p 2222 labuser@127.0.0.1
```

The `ssh` command above runs on the **host** for the NAT forwarding example. A connection refusal, timeout and authentication failure are different symptoms:

- **Refused:** the destination replied, but nothing accepted the TCP connection at that address/port.
- **Timeout:** investigate routing, forwarding and firewall drops.
- **Permission denied:** transport may work, but authentication or account policy failed.

## Things I actually encountered

My original notebook shows a VS Code Remote-SSH download problem and several later SSH configuration tests. Changing the VM's IP address alone would not necessarily fix a VS Code server-download issue. I would separate that from the SSH transport/authentication checks rather than claiming a single cause I never proved.

I also tested root login restrictions, password authentication limits and a non-default SSH port. Those tests are documented under the existing [Secure SSH Configuration course](../notes/21-secure-ssh-configuration.md). Changing the SSH port is **not a replacement** for strong authentication, least privilege and firewall restrictions.

## Sources

- [VirtualBox network modes and NAT port forwarding (Oracle)](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/networkingdetails.html)
- [RHEL 10 networking (Red Hat)](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html-single/configuring_and_managing_networking/index)
