# Low disk space or a slow server

I practised `df`, `du`, `top`, `vmstat`, `iostat`, `sar`, `journalctl` and log rotation on my lab VM. If a server starts failing writes, I'd first work out whether it is out of **space**, out of **inodes**, stuck on **I/O**, or short of **memory**. Those feel similar to users but need different fixes.

## Read-only checks first

```bash
df -hT
df -i
lsblk -f
sudo du -xhd1 /var 2>/dev/null | sort -h
journalctl --disk-usage
free -h
vmstat 2 5
```

If `/var` is filling up, use a narrower `du` search to find the directory responsible. For an unexpectedly large deleted log file, `lsof +L1` can reveal that a process still has the deleted inode open. Simply removing a visible file may not reclaim the bytes until the process releases it.

```bash
sudo lsof +L1
sudo journalctl -p err -b --no-pager -n 50
sudo iostat -xz 1 3
```

`iostat` needs the `sysstat` package. High `%iowait` alone is a clue rather than proof of a bad disk: compare device activity, latency, queueing and application symptoms. `sar` needs historical collection enabled if I want past data.

## What not to do under pressure

- Don't blindly delete everything under `/var/log`, `/var/lib` or container volumes.
- Don't run filesystem repair utilities on a mounted live filesystem just because a log mentions I/O.
- Don't assume disk pressure means storage needs extending before checking for runaway logs and retention policies.
- Don't change swappiness or I/O schedulers without measuring the workload before and after.

My original lab included forcing `logrotate`, but a test of rotation isn't the same as a validated retention policy. For production I'd review application-owned logrotate files and journald settings before changing them.
