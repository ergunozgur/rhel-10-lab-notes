# A backup that hasn't been restored is an untested backup

I used `tar` to archive `/etc` and individual configuration trees in my training VM, and wrote a simple script around it. One filename accidentally said `.tar.xz` while the command used gzip. That's a good reminder that the *name* isn't the format.

## Correct formats

```bash
# gzip archive
sudo tar -czf /var/tmp/example-configs.tar.gz /etc/example

# xz archive (normally slower, often smaller)
sudo tar -cJf /var/tmp/example-configs.tar.xz /etc/example
```

For a non-production example, inspect and extract into a temporary directory:

```bash
tar -tzf /var/tmp/example-configs.tar.gz | head
mkdir -p /var/tmp/restore-test
tar -xzf /var/tmp/example-configs.tar.gz -C /var/tmp/restore-test
```

A `tar` archive of an active database may not be consistent. An application-consistent database backup may require its own snapshot/dump method. Also consider ownership, SELinux labels, ACLs, links, secrets, permissions and files changing during capture. Tar may need extra flags to preserve specific metadata; ordinary examples aren't a substitute for a full system recovery strategy.

## Before believing the backup

- Confirm it contains the expected paths, metadata and versions.
- Restore into a safe temporary environment or separate VM and test service startup.
- Check who can read the backup: `/etc` may contain sensitive secrets.
- Follow backup retention rules and off-host/offline protection suitable for the environment.
- Document recovery order and dependencies, not only the archive command.

My recorded exercise covers creating an archive, not a full system recovery. The checks above are additional operational guidance rather than claims about what I demonstrated in the VM.
