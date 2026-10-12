# Packages and updates: prefer being able to explain the change

I learned the distinction between installing an RPM directly with `rpm -ivh` and letting DNF resolve package dependencies. I also had to repair a local repository configuration typo and temporarily disable a repo that no longer had its ISO mounted.

Before touching a production server I'd record the RHEL release, enabled repos, what packages will change and the recovery path:

```bash
cat /etc/redhat-release
dnf repolist
dnf history
dnf check-update
rpm -q <package>
rpm -qi <package>
rpm -qf /path/to/installed/file
```

`dnf check-update` returns exit code **100** when updates are available; that doesn't mean the command failed operationally. For specific security advisories use the installed DNF functionality, update information and local organizational patch policy. Don't blindly schedule every update with `-y` on a critical host without testing or change controls.

For a local RPM, `dnf install ./file.rpm` can resolve dependencies from **enabled repositories**, while `rpm -ivh` doesn't automatically retrieve missing packages.

When a service breaks after an update, note the package history, unit logs, configuration changes and whether a rollback is supported for that package and state. `dnf history undo` is not a universal guarantee of restoring applications or databases.

For offline media, check whether `BaseOS/` and `AppStream/` each contain `repodata` and configure the actual path rather than treating the ISO root as a single general repo. Keep package signature verification enabled with trusted keys when practical.
