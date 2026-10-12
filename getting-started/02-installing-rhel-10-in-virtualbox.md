# Installing RHEL 10 in VirtualBox

My labs ran on **RHEL 10 inside VirtualBox**. The original notebook starts with an already installed VM, so this page is a **reproducible installation reference**, not a minute-by-minute log of the exact buttons I clicked back then.

## Getting the image

I would download RHEL from the [Red Hat Developer download page](https://developers.redhat.com/products/rhel/download) using my own Red Hat account. The available download formats include:

- **DVD ISO:** Contains installation content locally. Usually the simpler choice for an offline or unreliable-network lab.
- **Boot ISO:** Starts the installer but needs access to package repositories or another installation source.

Pick the **x86_64** ISO for an x86-64 PC/VirtualBox guest. An `aarch64` ISO is for ARM64 environments and is not a drop-in replacement.

I would compare the ISO's SHA-256 hash to the checksum on the download page before using it. For example, on Linux:

```bash
sha256sum ~/Downloads/rhel-10-*-x86_64-dvd.iso
```

The filename and expected hash depend on the actual release. Don't copy a checksum from someone else's notes.

## Creating the VM

My reasonable **lab starting point**, not a claim about RHEL's minimum hardware requirements:

| Setting | Example for a disposable study VM |
|---|---|
| Guest | 64-bit Linux / Red Hat family |
| CPU | 2 virtual CPUs (more if the host has room) |
| Memory | 4–8 GiB if available; a minimal CLI guest may need less |
| Disk | 40 GiB or more, dynamically allocated |
| Installation media | Attach the RHEL 10 ISO to the VM's virtual optical drive |
| Network | NAT for internet access; use a second adapter or port forwarding when appropriate |

The official installation requirements are separate from these comfortable *lab* values. Check [Red Hat's current requirements](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html-single/interactively_installing_rhel_from_installation_media/index) before planning another environment. VirtualBox is where **I studied**, not a statement about Red Hat's supported hypervisor list.

A **snapshot before destructive disk, SELinux, SSH or firewall experiments** is handy. A snapshot is convenient in a lab but not a substitute for an actual backup.

## Installer walkthrough

The exact screens may differ a little by RHEL 10 minor version and installer build:

1. Boot the VM with the ISO attached and start the RHEL installer.
2. Select language/keyboard and inspect the installation destination. Make sure it is **the VM's virtual disk**, not any physical host drive.
3. Choose a software environment. A **minimal installation** is ideal for learning to manage a server from the CLI; a GUI environment can be useful for learning GNOME and graphical tools.
4. Check networking, timezone, storage and account settings. Make a normal account with administrative access rather than using root for every lab.
5. Run the installation, reboot, and detach the installation ISO if the VM tries to boot the installer again.
6. After the first login, verify the actual operating system release and the network before installing additional packages.

I used both terminal and GNOME in the training, and also practised changing `graphical.target` and `multi-user.target` later. The target can be inspected with:

```bash
systemctl get-default
systemctl list-units --type=target
```

Changing the target affects boot behavior. Use the console to test it, especially if you're on a remote machine.

## What I would inspect first

```bash
cat /etc/redhat-release
uname -m
hostnamectl
lsblk -f
findmnt /
free -h
nmcli device status
ip -br address
ip route
```

`lsblk` and `findmnt` make the relationship between disks, partitions, logical volumes, filesystems and mount points much easier to understand than guessing from device names.

> I performed storage labs with **an additional VirtualBox disk**. Commands such as `fdisk`, `pvcreate`, `mkfs.xfs` and `wipefs` are destructive. Never paste an example `/dev/sdb` from my notes onto another machine without checking which device it actually is.

## If the installer cannot continue

- **No disk listed:** check that the virtual disk exists and is attached to a controller that the guest can recognize.
- **No network/package source with Boot ISO:** the Boot ISO is not the same as the full DVD ISO; configure repository access or use the DVD ISO.
- **Host is running out of memory:** lower guest allocation or use a less demanding installation environment, rather than starving the host.
- **VM keeps showing the installer again:** check boot order and remove the ISO after installation.

I wouldn't try to solve boot or networking problems by disabling SELinux. They are separate systems.

## Sources

- [Interactive RHEL 10 installation (Red Hat)](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html-single/interactively_installing_rhel_from_installation_media/index)
- [Red Hat RHEL downloads](https://developers.redhat.com/products/rhel/download)
- [Oracle VirtualBox networking](https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/networkingdetails.html)
