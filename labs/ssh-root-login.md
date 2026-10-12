# SSH: root login wasn't behaving the way I expected

I wanted to disable direct root SSH login in the RHEL 10 VM. I backed up the main `sshd_config` file, changed `PermitRootLogin` to `no`, tested the syntax, and restarted SSH.

```console
# sshd -t
# systemctl restart sshd
```

I still thought the login restriction wasn't taking effect, so I checked both the main file and the configuration directory. In my notes, the main file said `no` while a drop-in had `yes`:

```text
/etc/ssh/sshd_config:PermitRootLogin no
/etc/ssh/sshd_config.d/01-permitrootlogin.conf:PermitRootLogin yes
```

That was confusing, but the effective check reported:

```console
# sshd -T | grep -i permitrootlogin
permitrootlogin no
```

In a later local test, an attempted root password login returned `Permission denied`, while my normal account could still use `sudo`. However, **one rejected password is not enough to prove that root login is fully blocked**; an incorrect password would also be denied. The recorded `sshd -T` result was `permitrootlogin no`, but I didn't capture a complete connection-specific `sshd -T -C ...` check or a known-valid-root-credential test. I should keep that uncertainty in the note instead of declaring the issue conclusively resolved.

The useful lesson wasn't "restart SSH again." It was to check **which config values are actually effective**. The first matching setting, included files, and `Match` rules can matter. `sshd -t` only checks syntax; `sshd -T` shows effective settings. When `Match` blocks are involved I also need `sshd -T -C ...` with the relevant connection properties.

I kept a separate session open during the test. That's important when changing SSH remotely, otherwise a successful security change can turn into a very annoying lockout.
