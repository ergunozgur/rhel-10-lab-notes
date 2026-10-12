# My backup script and a timestamp typo

I wrote a small Bash backup script with `tar`, made it executable and ran it. It produced an archive and printed a completion message. Later I wrote another function to append timestamped messages to a log file.

The log displayed this strange string repeatedly:

```text
2026-07-26 &T- start
```

My `date` format had `&T` instead of `%T`. The command was working as written; I had written the format wrong. The repaired form is:

```bash
log() {
  printf '%s - %s\n' "$(date '+%F %T')" "$1" >> "$LOG"
}
```

A second lesson: I named one archive `.tar.xz` but used `tar -czf`, which produces **gzip**, not xz compression. The extension doesn't change the format. Use `tar -cJf archive.tar.xz ...` for xz, or `tar -czf archive.tar.gz ...` for gzip.

Creating a backup archive is not the same as validating a restorable backup. I didn't verify a restore from that script. For future use, I want to list the archive, extract into a temporary directory, and check the result. See [backup reference](../reference/backup-and-recovery.md).
