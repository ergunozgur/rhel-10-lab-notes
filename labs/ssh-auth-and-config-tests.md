# SSH: too many authentication failures, then a config typo

While experimenting with SSH on port `2222`, I reduced `MaxAuthTries` to `3` and tested a login from the Windows SSH client. After multiple wrong passwords, the connection ended with:

```console
Permission denied, please try again.
Permission denied, please try again.
Received disconnect from 127.0.0.1 port 2222:2: Too many authentication failures
```

In this specific test, the disconnect happened after failed password attempts. The error can have other causes too, including a client offering too many keys, so the message alone doesn't tell the whole story.

Later, I deliberately misspelled `Port` as `Portt` in `sshd_config` to see what a configuration check would catch:

```console
# sshd -t
/etc/ssh/sshd_config: line 21: Bad configuration option: Portt
/etc/ssh/sshd_config: terminating, 1 bad configuration options
```

Once I fixed the spelling, `sshd -t` returned without an error. I also tested `ssh -v` and `ssh -vvv` on the client to see the connection and authentication steps.

A useful distinction: `sshd -t` checks whether the configuration is valid. It doesn't prove that a login is allowed, that the daemon can bind to its configured port under SELinux, or that the connection works end to end. For those, I need the effective settings, service logs and a new client test.
