# A systemd timer that actually ran

I wanted to try scheduling a script without cron. I wrote a small uptime logger:

```bash
#!/bin/bash
echo "Uptime Log: $(date)" >> /var/log/uptime.log
uptime >> /var/log/uptime.log
echo "----------------------------------------" >> /var/log/uptime.log
```

Then I created a one-shot service for that script and a timer that ran after boot and repeated every minute:

```ini
[Unit]
Description=Run uptime logger every 1 minute

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
Unit=uptime-logger.service

[Install]
WantedBy=timers.target
```

After adding the unit files:

```console
# systemctl daemon-reload
# systemctl enable --now uptime-logger.timer
# systemctl list-timers --all
# cat /var/log/uptime.log
```

My log showed several entries, one minute apart. It worked.

I also ran `systemctl daemon-reexec` during that exercise. For ordinary changes to unit files, `daemon-reload` is enough; I didn't need to re-execute systemd for this.

The corrected script and an example unit pair are under [`../scripts/`](../scripts/).
