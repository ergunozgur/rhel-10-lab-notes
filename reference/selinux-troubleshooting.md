# SELinux: look for the denial before changing the policy

My notes include both a legitimate test of changing and restoring a file label, and a less convincing case where I assumed an SSH home label was wrong without capturing a denial. Those are very different situations.

## Which layer is stopping the action?

First check ordinary file modes, owning user/group, path traversal and service state. SELinux is an additional policy layer, not a replacement for those checks. Then inspect:

```bash
getenforce
sestatus
ls -ldZ /path/to/directory
ls -lZ /path/to/file
matchpathcon /path/to/file
sudo ausearch -m AVC,USER_AVC -ts recent
sudo journalctl -t setroubleshoot --since '30 minutes ago'
```

A missing AVC is not guaranteed proof that SELinux is innocent, but a real denial makes the diagnosis much stronger. `setenforce 0` can be a temporary *controlled diagnostic* on a permitted test host, not a fix or normal security hardening approach; re-enable enforcing and address the policy issue instead.

## When the file type is wrong

`restorecon` applies the default policy context. Preview it with `restorecon -nRv /path` if the correct policy mapping exists. For a deliberate nonstandard web root, the pattern may be:

```bash
sudo semanage fcontext -a -t httpd_sys_content_t '/srv/example-web(/.*)?'
sudo restorecon -Rv /srv/example-web
```

That's an **example** and requires confirming the directory's intended use first. A direct `chcon` can be overwritten by a later relabel. If a service needs to connect to a backend, a relevant SELinux Boolean might be involved, but verify the exact behavior before enabling it permanently.

## Ports are labels too

For a nondefault SSH listener, Red Hat documents adding the port to `ssh_port_t` with `semanage port` and separately allowing the port through firewalld. Check whether the port is already assigned to another type before adding it; if the type already exists, `-m` rather than `-a` may be appropriate.

## What the recorded example proves

The captured `chcon`/`restorecon` exercise proves that the SELinux label changed and was restored. It is not evidence of a separate web-service denial or a successful HTTP request. For diagnosing an actual denial, use the log and context checks above.

Reference: [Using SELinux on RHEL 10](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html-single/using_selinux/index).
