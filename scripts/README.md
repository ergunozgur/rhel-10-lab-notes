# Small Bash exercises

These are corrected or slightly expanded versions of scripts I tried during the RHEL training. The original working notes were rough; I kept the idea and cleaned up the parts worth reusing.

- `check-internet.sh`: my early `ping`/exit-status exercise. This is an ICMP reachability check, not proof that DNS or HTTP works.
- `disk-usage-check.sh`: corrected the missing variable expansion in my `elif` test. You can pass a mount point as the first argument.
- `uptime-logger.sh`: appends date/time and `uptime` to a log; defaults to `/var/log/uptime.log`, so use a writable test file path if you're running without root.
- `uptime-logger.service.example` and `.timer.example`: examples from my timer exercise. Copy them into the appropriate locations only in a test environment, point `ExecStart` at your installed script, then run `systemctl daemon-reload`.

Check syntax without executing a script:

```bash
for f in scripts/*.sh; do bash -n "$f"; done
```
