# DNF: a typo in my local repository file

I tried creating a local repository during the package management exercises. My first configuration looked like this:

```ini
[LocalRepo]
nam=RHEL 10.2 Local Repo
baseurl=file:///mnt/rhel
enabled=1
gpgcheck=0
```

`dnf repolist` showed a warning:

```text
Repository 'LocalRepo' is missing name in configuration, using id.
```

I had written `nam` instead of `name`. Easy to miss after staring at the file for a while.

```ini
name=RHEL 10.2 Local Repo
```

There was another problem with the example worth noting: a RHEL installation DVD commonly has separate `BaseOS` and `AppStream` repository directories, so setting the `baseurl` to the mount root doesn't necessarily point to working repository metadata. Seeing a repository in `repolist` **isn't proof that packages can be installed from it**. My original notes don't show a successful installation from this local repository.

Later I removed it from the active configuration because I no longer had the ISO available:

```console
# mv /etc/yum.repos.d/local.repo /etc/yum.repos.d/local.repo.bak
# dnf clean all
# dnf makecache
```

I also used `gpgcheck=0` in this isolated test. That shouldn't be the default for a real repository; use verified signing keys instead.
