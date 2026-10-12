# SSH changes without losing the only way back in

I managed to confuse myself with `PermitRootLogin` settings in a main file and an included drop-in. I also moved a test server to port 2222 and hit SELinux. Both made me appreciate checking the **effective** configuration and preserving a recovery path.

## Read first

```bash
sudo sshd -t
sudo sshd -T | grep -E '^(port|permitrootlogin|passwordauthentication|pubkeyauthentication) '
sudo grep -RniE '^(Include|Match|PermitRootLogin|PasswordAuthentication|Port|AllowUsers)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d 2>/dev/null
sudo systemctl cat sshd
```

OpenSSH config parsing is sensitive to include order and the first obtained value for many keywords. A `Match` block can change the answer for a particular client. For a specific test, use `sshd -T -C user=root,host=example,addr=192.0.2.20` with appropriate actual values. `sshd -t` validates syntax, not network reachability or SELinux policy.

## Change procedure I would follow remotely

- Keep the current session and a console or second admin path available. Test a **second, fresh session** before disconnecting the original one.
- Back up the original configuration and read existing drop-ins before adding new ones.
- Prefer a named personal account with `sudo` over routine direct root login.
- Confirm a working public-key login before disabling passwords.
- For port changes, check `semanage port -l | grep ssh_port_t` **and** the actual firewalld interface zone. A new firewall opening by itself does not allow SELinux to bind a process to that port.
- Use `sudo sshd -t` before applying; if supported, `systemctl reload sshd` avoids interrupting existing sessions, but still test a fresh connection.

Example diagnostics, not a copy-and-run change script:

```bash
sudo journalctl -u sshd --since '15 minutes ago'
sudo ss -lntp | grep sshd
sudo semanage port -l | grep ssh_port_t
sudo firewall-cmd --get-active-zones
ssh -vvv user@<test-server>
```

A different SSH port reduces irrelevant scans but is not equivalent to authentication hardening. For remote lockouts, consult a runbook with console access, not blind `systemctl restart sshd` loops.

Official background: [Red Hat RHEL 10: OpenSSH](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/securing_networks/using-secure-communications-between-two-systems-with-openssh).
