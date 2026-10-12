# Red Hat and RHEL: the basics

Before the commands, I want a quick picture of what I'm actually running.

**Red Hat** is the company. **Red Hat Enterprise Linux (RHEL)** is its enterprise Linux distribution. RHEL is used for servers, workstations, VMs, and cloud workloads. The point isn't that its commands are magically different from every other Linux distribution; the enterprise part is the predictable lifecycle, package ecosystem, updates, security tools, and supported deployment options.

## RHEL, Fedora and CentOS Stream

These aren't interchangeable names:

- **Fedora** is an upstream project where a lot of new Linux technology develops. Future RHEL major releases draw from Fedora.
- **CentOS Stream** is the continuously delivered upstream development platform for the next RHEL minor updates.
- **RHEL** is the product released and maintained for enterprise workloads.

That is a simplified relationship, but enough to explain why I wouldn't blindly use instructions from Fedora on an RHEL server.

## What is included in a RHEL system?

The main building blocks I keep running into in my labs:

| Component | What I use it for |
|---|---|
| Linux kernel | Talks to hardware and provides processes, memory, filesystems, drivers and networking |
| systemd | Starts and manages system services, mounts and timers |
| NetworkManager / `nmcli` | Network profiles, interfaces, IP, routes and DNS |
| RPM + DNF | Software packages, repositories, updates and dependencies |
| SELinux | Mandatory access control beyond ordinary Unix permissions |
| firewalld | Host firewall zones and allowed network services |
| journald / rsyslog | Logs and incident investigation |
| Podman | Running and managing OCI containers |
| LVM and XFS/ext4 | Flexible storage and filesystems |

RHEL 10 uses **BaseOS** for core operating-system components and **AppStream** for additional applications and runtimes. Both are part of a normal RHEL system. There's also CodeReady Linux Builder for developer-oriented packages, but its content has different support terms.

```bash
cat /etc/redhat-release
cat /etc/os-release
uname -r
uname -m
rpm -q systemd
sudo dnf repolist
```

These are **reference checks**, not a claim that I captured every output while installing my VM.

## Red Hat's other products

I noted these names early in my training, so this is the short version I actually want to remember:

- **Red Hat Satellite:** managing many RHEL systems, their content and lifecycle.
- **Red Hat Ansible Automation Platform:** automating configurations and operations across systems.
- **Red Hat OpenShift:** application and container orchestration built around Kubernetes.
- **Red Hat Lightspeed / Insights:** analysis and operational recommendations for connected Red Hat systems, depending on the services configured.

RHEL is the operating-system foundation; those other products solve management, automation or platform problems around it.

## What happens during boot?

My shorthand from the original notes was:

```text
Firmware (BIOS / UEFI)
  -> Bootloader (GRUB)
  -> Kernel + initramfs
  -> systemd (PID 1)
  -> Services, mounts, network, targets
  -> Login on a console, over SSH or through a GUI
```

`initramfs` is an early userspace environment used to prepare access to the real root filesystem. It **does not** start all of the normal services; systemd takes care of the later userspace initialization. This distinction matters when troubleshooting a machine that cannot boot.

```bash
ps -p 1 -o pid,comm=
systemctl get-default
systemctl --failed
journalctl -b -p warning
lsblk -f
```

I can then jump to [the systemd course notes](../notes/14-control-services-and-daemons.md) or [the storage course notes](../notes/09-storage-and-logical-volume-management.md) for the real lab work.

## Sources

- [What is CentOS Stream? (Red Hat)](https://www.redhat.com/en/topics/linux/what-is-centos-stream)
- [RHEL platform overview (Red Hat)](https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux)
- [RHEL 10 repositories (Red Hat)](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/managing_software_with_the_dnf_tool/distribution-of-content-in-rhel-10)
