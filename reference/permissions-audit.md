# Users, sudo, groups and ACLs: check the whole path

In my lab, `useradd` failed when I referred to a group that didn't exist, and ACL permissions behaved differently once I changed the mask. The main lesson: the mode bits shown by `ls -l` are only part of the picture.

## Identity and login

```bash
id <user>
getent passwd <user>
getent group <group>
chage -l <user>
passwd -S <user>
sudo -l -U <user>
```

Managed hosts may use SSSD, LDAP or another identity provider, so not every account exists as a local `/etc/passwd` entry. Password locks and account expirations affect authentication differently; verify the intended login path instead of assuming one command revokes every possible session or SSH key.

## File and directory permissions

```bash
namei -l /path/to/target
stat /path/to/target
getfacl /path/to/target
ls -ldZ /path/to/target
```

A user needs execute/search permission on directories in the path. Named ACL entries can be limited by the **ACL mask**. Default ACLs apply to newly created children of a **directory**, not to an existing file retroactively. My first inheritance test didn't create its file where I thought it did, so I still want to repeat it properly.

For sudo access, use `visudo` or `visudo -f /etc/sudoers.d/<rule>` rather than direct edits without syntax validation. Avoid `NOPASSWD: ALL` as a reflexive shortcut; grant specific duties according to policy.

Don't use recursive `chmod 777` to troubleshoot permissions. Find whether the cause is ownership, group membership, ACL masks, SELinux, a mount option or a service account.
