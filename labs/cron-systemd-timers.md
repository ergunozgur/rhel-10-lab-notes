# Cron, `at` and systemd timers all solved slightly different problems

I tried a recurring cron job that appended the date/time to a file, and I verified successive entries a minute apart. I also scheduled a one-time job using `at` and checked the queue with `atq`.

```crontab
* * * * * /root/logtime.sh >> /root/cron_output.txt 2>&1
```

My actual log had consecutive timestamps. That was a useful check because simply saving a crontab doesn't prove the job runs or has the right environment.

I also built a systemd timer for an uptime logger, and that output was captured too. What I want to remember:

- cron uses a limited environment. Absolute paths and explicit logging help.
- `crontab -r` removes the entire user's crontab, so it deserves more care than a single-line edit.
- `at` is for one-off jobs, and `atq` / `atrm` inspect and cancel them.
- systemd timers have logs and dependency integration through their services, but they aren't a universal replacement for cron.

A separate operational detail: for missed runs while the machine is off, calendar timers can use `Persistent=true`. Cron and anacron have different catch-up behavior.
