# NetworkManager: static and DHCP profiles

In the RHEL networking section I examined `nmcli device`, active connection profiles, the IP address, and the default route. I also practised moving a lab connection between DHCP and static addressing. The useful thing to remember is that **a device** and **its NetworkManager connection profile** are different objects.

Commands from my working notes:

```bash
nmcli device status
nmcli connection show
nmcli connection show --active
nmcli device show
ip address
ip route
```

A profile can exist without being active, and a configuration change doesn't prove traffic works. For a static address test I'd verify the assigned address, gateway, DNS and route *after activating* the intended profile, then check a second host.

The original scratchpad shows multiple IP/mask and hostname exercises, but it does not preserve one complete final before/after result for every change. I won't invent one. For remote machines I also wouldn't run `nmcli connection down` casually over the only SSH connection; console access or a rollback mechanism matters.

See [network troubleshooting order](../reference/network-diagnostics.md).
