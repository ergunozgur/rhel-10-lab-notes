# SELinux Boolean: `httpd_can_network_connect`

I checked whether Apache was allowed to make outgoing network connections:

```console
# getsebool httpd_can_network_connect
httpd_can_network_connect --> off
```

Then I toggled it on and off temporarily with `setsebool`, and later enabled it persistently using `-P`. My notes show the flag changing as expected:

```bash
setsebool httpd_can_network_connect on
getsebool httpd_can_network_connect
setsebool httpd_can_network_connect off
setsebool -P httpd_can_network_connect on
```

This **only verifies a policy Boolean changed**. It doesn't show an Apache backend connection suddenly started working, because I didn't build that end-to-end test in the notebook.

A production service shouldn't enable every httpd Boolean just in case. I would first check whether a denial exists, confirm the expected network behavior and review the specific Boolean's implications. Setting `-P` also makes the policy change survive reboot.
