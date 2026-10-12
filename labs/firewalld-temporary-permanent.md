# Firewalld: runtime vs permanent rules

I created and inspected service, port and zone rules in the RHEL lab, including a TCP application port, NFS-related services and richer rules. I used `--permanent` followed by `--reload` in several tests and saw the new entry in `--list-all` afterward.

```bash
firewall-cmd --get-active-zones
firewall-cmd --list-all
firewall-cmd --permanent --add-port=8081/tcp
firewall-cmd --reload
firewall-cmd --list-ports
```

What I want to remember: runtime and permanent rules are two separate states. `--reload` reads the saved permanent configuration and can discard runtime-only modifications. A rule in a zone that the interface isn't using won't give the access I expect.

There are many more experiments in the original notebook than would be useful as a giant pasted firewall dump. I kept the commands I can reuse and linked the [change-safety reference](../reference/firewalld-change-safety.md). I didn't establish an end-to-end successful connection for every single rich rule, so this is not a claim that every firewall test passed.
