# First boot, registration and repositories

This one comes directly from a problem I hit in the lab: **my initial trial expired and package operations stopped working**. I moved to a Red Hat Developer Subscription for Individuals. My original notebook records:

```console
$ sudo subscription-manager unregister
$ sudo subscription-manager clean
$ sudo subscription-manager register
$ sudo dnf repolist
```

After that, I noted that package management was working again. That sequence reflects **what I did in my lab**. It isn't the recommended first step for every RHEL system: `unregister` and `clean` deliberately remove existing registration information and are not harmless diagnostics, especially on a company-managed machine.

## A normal first-pass check

```bash
cat /etc/redhat-release
hostnamectl
nmcli device status
ip route
sudo subscription-manager identity
sudo subscription-manager status
sudo subscription-manager repos --list-enabled
sudo dnf repolist
sudo dnf makecache
```

I look at them in that order: first confirm the OS and connectivity, then identity/content access, then the repositories DNF can actually use.

If the host isn't registered and I have a suitable Red Hat subscription/account, interactive registration can be done with:

```bash
sudo subscription-manager register
```

Don't put Red Hat account passwords, activation keys, or registration output containing unique system identifiers into a public GitHub note. An organization's managed machines can have a different registration workflow; **do not re-register one against a personal account**.

## A note about subscription status

With **Simple Content Access (SCA)**, older tools sometimes reported `Overall Status: Disabled` even when repository access was valid. Newer RHEL 10 builds can display clearer `Registered` / `Not Registered` language. `subscription-manager identity` and actual repository availability are more useful checks than judging only that single status string.

## BaseOS vs AppStream

These are the two main repository families I want to remember:

- **BaseOS:** core OS content.
- **AppStream:** additional applications and runtimes.

```bash
sudo dnf repolist --all
sudo dnf search nginx
sudo dnf info nginx
sudo dnf provides '*/sshd'
sudo dnf history
```

If `dnf repolist` is empty or repositories are disabled, check account registration, access and enabled repo IDs first. A `dnf` failure isn't always a DNS issue, and it's not always a subscription problem either. Check the error before changing anything.

## Updating after installation

Once repositories work, a standard reference command is:

```bash
sudo dnf upgrade --refresh
```

Read which packages will be updated before confirming, especially outside a disposable VM. Check whether a kernel or other component requires rebooting and plan accordingly; don't assume a reboot is always free of consequences.

```bash
sudo dnf history
rpm -q kernel
systemctl --failed
getenforce
sudo firewall-cmd --state
```

I also used `dnf install httpd`, `systemctl start httpd`, and `systemctl status httpd` while practising the package/service workflow. See [my package management notes](../notes/05-linux-package-management.md).

## A safe troubleshooting order

When the repositories are missing, I'd rather inspect before resetting registration:

```bash
sudo subscription-manager identity
sudo subscription-manager repos --list-enabled
sudo dnf repolist --all
nmcli general status
ip route
getent hosts cdn.redhat.com
```

If things look registered but the CDN is unreachable, consider DNS, network, proxy and TLS issues. For managed hosts, check whether content should come from Satellite or an internal mirror instead. Only reset registration when the root cause calls for it and the correct credentials/process are available.

## Sources

- [RHEL 10 registration (Red Hat)](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/automatically_installing_rhel/registering-your-rhel-system)
- [RHEL 10 repository types (Red Hat)](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/managing_software_with_the_dnf_tool/distribution-of-content-in-rhel-10)
- [RHEL 10 package searching and repos (Red Hat)](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/managing_software_with_the_dnf_tool/searching-for-rhel-content)
- [Simple Content Access subscription status (Red Hat)](https://access.redhat.com/solutions/7080864)
