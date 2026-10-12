# SSH port 2222: the firewall wasn't the only piece

I changed the SSH port from the default to **2222** in my RHEL lab. I added the TCP port to firewalld and reloaded the rules:

```console
# firewall-cmd --permanent --add-port=2222/tcp
success
# firewall-cmd --reload
success
```

`sshd -t` gave no syntax errors, but restarting the service failed:

```text
Job for sshd.service failed because the control process exited with error code.
```

The lab had SELinux in enforcing mode. After adding the non-default port to the `ssh_port_t` policy type, SSH restarted:

```console
# semanage port -a -t ssh_port_t -p tcp 2222
# systemctl restart sshd
# getenforce
Enforcing
```

Then I tested connecting to port 2222 from the client.

A firewall rule allowing a port doesn't mean SELinux will let the service bind to it. And `sshd -t` won't necessarily catch a policy denial that only happens when the service starts. I'd check `systemctl status sshd` and `journalctl -xeu sshd` before changing anything else.

**Lab only:** Before changing a production SSH port, keep a working remote session and provide a tested fallback. Changing the port alone isn't a substitute for SSH keys and proper access controls.
