# A service is down: my first ten minutes

It's tempting to restart a service immediately. Sometimes that works, but it can remove clues. I'd rather capture what I can *before* making changes, especially if an outage started after a deployment or config edit.

## Find the actual unit and what failed

```bash
systemctl --failed
systemctl status example.service --no-pager -l
systemctl show example.service -p ActiveState -p SubState -p Result -p ExecMainStatus
systemctl cat example.service
```

The unit file and its drop-ins tell me what systemd *was asked* to run. Status and logs tell me what it *actually* managed to start. A service can be `active (exited)` for a valid one-shot operation, so `running` isn't the only good status.

```bash
journalctl -u example.service -b --no-pager -n 100
journalctl -u example.service --since '30 minutes ago' --no-pager
systemctl list-dependencies example.service
```

If a config was recently edited, check the service's own validation command first. For SSH, it's `sshd -t`; for an rsyslog configuration, `rsyslogd -N1`. Don't assume every application has the same validation flag.

## Before a restart

1. Note the last known good state and the exact failure time.
2. Check whether a change, package update, disk-full event, permission issue or certificate expiry coincided with the failure.
3. Verify whether the process is listening where clients expect it: `ss -lntup`.
4. If there is a systemd drop-in, read it with `systemctl cat` rather than editing the packaged unit directly.
5. Decide whether `reload` applies config without interrupting live sessions; check `systemctl show -p CanReload example.service`.

After changing a unit file, `systemctl daemon-reload` refreshes the unit definitions. It is not the same as restarting the service and does not by itself reload the application configuration.

## A lesson from my lab

I ran a custom one-shot service and a timer and verified timestamps in the output log. That proved the timer fired for that test. It didn't prove how it behaves across missed schedules or machine downtime. Those are separate tests worth doing.
