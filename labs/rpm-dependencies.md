# RPM dependencies: I tried installing Apache the hard way

During the package management section, I removed `httpd`, downloaded the RPM, and tried installing it manually with `rpm -ivh`.

```console
# rpm -ivh httpd-2.4.63-13.el10_2.4.x86_64.rpm
error: Failed dependencies:
    httpd-core = 0:2.4.63-13.el10_2.4 is needed
    system-logos(httpd-logo-ng) is needed
```

That made the difference between `rpm` and `dnf` much clearer. `rpm` is useful for inspecting and working with packages, but it doesn't automatically fetch their dependencies.

For normal installations I'd use:

```console
# dnf install httpd
```

Or, if I already have a local RPM and the dependencies are in enabled repositories:

```console
# dnf install ./package.rpm
```

I had previously checked packages with `rpm -q`, `-qi`, `-ql`, and `-qf`. This was the first practical example in my notes where installing the downloaded RPM directly didn't work.
