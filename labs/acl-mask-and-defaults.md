# ACLs: `rwx` on paper, read-only in practice

This one made more sense once I looked at the **effective** permissions rather than just the ACL entry.

I was testing ACLs on an ext4 lab partition. I granted a test user called `useracl` read, write and execute permissions on `file2.txt`:

```console
# setfacl -m u:useracl:rwx file2.txt
# getfacl file2.txt
user::rw-
user:useracl:rwx
group::r--
mask::rwx
other::r--
```

Then I changed the mask:

```console
# setfacl -m mask:r-- file2.txt
# getfacl file2.txt
user::rw-
user:useracl:rwx                #effective:r--
group::r--
mask::r--
other::r--
```

The named user's entry still said `rwx`, but the mask reduced its **effective** permissions to `r--`. That `#effective:` comment was the part I needed to notice.

I also tried to create a *default* ACL on an ordinary file:

```console
# setfacl -d -m u:useracl:rx file.txt
setfacl: file.txt: Only directories can have default ACLs
```

Default ACLs belong on directories, so I created a test directory and added the entry there instead:

```console
# mkdir default
# setfacl -d -m u:useracl:rx /mnt/acltest/default/
# getfacl /mnt/acltest/default/
default:user::rwx
default:user:useracl:r-x
default:group::r-x
default:mask::r-x
default:other::r-x
```

There's one more mistake in my original notebook: I used `touch test.txt /mnt/acltest/default/` while trying to test inheritance. That doesn't create `test.txt` *inside* the directory, so the output I captured does **not** prove inherited ACLs worked. To verify inheritance, create a file **inside** `/mnt/acltest/default/` and check the resulting `getfacl` output. The original command doesn't provide that evidence.

This lab taught me to look at both the ACL entry and the mask, and not to call something verified when I hadn't tested the actual resulting file.
