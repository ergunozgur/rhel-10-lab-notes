# rsyslog forwarding: sender-side configuration

I was experimenting with sending logs to a separate server. The sending VM had rsyslog enabled, and I added a forwarding rule pointing to a lab receiver at port 514, then restarted the service. I also added a UDP 514 firewall rule in the lab and saw it listed afterward.

The sending-side rule was in this form (address replaced with an example-only IP):

```rsyslog
*.* @192.0.2.10:514
```

I need to remember: `@` in traditional rsyslog syntax denotes UDP, and `@@` denotes TCP. This kind of legacy rule is a basic lab example, not my preferred secure logging design for a real network.

**What I actually checked:** rsyslog was running, the configuration was updated, and firewalld reported the UDP port allowed. **What I did not show:** a receiver accepting the message or a log file on the remote host containing it. Opening 514 on the *sender* is also not the same as ensuring the *receiver* permits inbound traffic.

For a real deployment, validate both sender and receiver configurations (`rsyslogd -N1`), send a recognizable message with `logger`, and confirm delivery on the receiver. Prefer an authenticated and encrypted transport, such as TCP with TLS, according to the environment's logging requirements.
