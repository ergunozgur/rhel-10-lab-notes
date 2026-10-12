# SELinux: changing a label and restoring it

I used a test HTML file under `/var/www/html/test/` to see how a file's SELinux context changes.

The file originally had the `httpd_sys_content_t` type:

```console
# ls -Z /var/www/html/test/hello.html
unconfined_u:object_r:httpd_sys_content_t:s0 /var/www/html/test/hello.html
```

I temporarily changed the type to `ssh_home_t`:

```console
# chcon -t ssh_home_t /var/www/html/test/hello.html
# ls -Z /var/www/html/test/hello.html
unconfined_u:object_r:ssh_home_t:s0 /var/www/html/test/hello.html
```

Then restored the default label:

```console
# restorecon /var/www/html/test/hello.html
# ls -Z /var/www/html/test/hello.html
unconfined_u:object_r:httpd_sys_content_t:s0 /var/www/html/test/hello.html
```

I also practised adding a persistent file-context mapping with `semanage fcontext`. In this case the default type was *already* `httpd_sys_content_t`, so that exercise wasn't evidence of a broken website being fixed.

The terminal output confirms the context changed and was restored. **I didn't capture an actual HTTP failure or an AVC denial for this test**, so I won't describe it as a resolved web-server outage.

For troubleshooting a real access problem I'd look at the current context, the expected policy context, and the relevant audit logs before changing labels or SELinux booleans.
