# SSH keys: the client matters

I generated a key pair on my Linux VM and copied the public key to a test user's `authorized_keys` through `ssh-copy-id`. The command reported that **one key had been added**. I then disabled SSH password authentication to try a key-only setup.

The confusing part came when I tried connecting from Windows. That client didn't have the private key I had generated on the Linux system, so this happened:

```console
PS> ssh mike@127.0.0.1
Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

I wrote down that it worked from the Linux shell that had the key, but I don't have a complete second-client success log. So I'm not calling the entire setup verified for Windows.

A better repeat of the exercise would be:

```bash
ssh -vvv -i ~/.ssh/lab_key mike@<lab-host>
# On the server, separately:
sshd -t
journalctl -u sshd --since '10 minutes ago'
```

Then check the *same* user's `~/.ssh/authorized_keys`, directory permissions, ownership and SELinux labels on the server. `ssh-copy-id` success says the key was installed, not that every client automatically knows which private key to use.

I wouldn't disable passwords on a remote production machine until **at least one fresh key-based session** worked and I had a tested fallback. See [safe SSH changes](../reference/ssh-safe-changes.md).
