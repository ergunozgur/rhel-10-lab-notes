# Users, password aging and the account I created more than once

I worked with `useradd`, `usermod`, `passwd`, `chage`, group membership and `visudo` in the VM. One early attempt to assign a new user to a group failed because the group didn't exist yet:

```console
# useradd -u 2025 -g demogroup demorhel
useradd: group 'demogroup' does not exist
```

I created the group first and repeated the command. Later I moved another user's home directory and deleted an account without `-r`. Recreating that account produced a warning about the pre-existing home directory. That's worth remembering: deleting the account entry and deleting the person's files aren't the same operation.

I also experimented with forcing a password change and limiting its lifetime:

```bash
passwd -e demo
chage -l demo
chage -m 5 -M 20 demo
chage -I 5 demo
```

Those commands help manage local password policy, but I'd check the organization's PAM, SSSD and identity-provider rules before applying any of them in a managed environment. Account locking and password locking don't always have identical effects on SSH key authentication or an existing session.

When applying account-policy changes on a real host, verify the resulting login behavior, not just the command's exit status. See [permissions reference](../reference/permissions-audit.md).
