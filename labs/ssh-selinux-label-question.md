# I thought `unconfined_u` meant the SSH key context was wrong

While checking `.ssh` file labels, my output included a type like this:

```text
unconfined_u:object_r:ssh_home_t:s0 id_rsa
```

At first I wrote that `unconfined_u` was evidence of an incorrect context and tried `restorecon -Rv ~/.ssh`, then `chcon -t ssh_home_t ~/.ssh`.

But the label already used **`ssh_home_t`**, the part most relevant to the file type in this test. `unconfined_u` by itself doesn't establish an SELinux problem. I don't have a related AVC denial in the notebook, nor proof that changing the label fixed authentication.

If I see an actual SSH key-related denial later, I'd inspect first:

```bash
ls -ldZ ~/.ssh
ls -lZ ~/.ssh/
matchpathcon ~/.ssh/authorized_keys
restorecon -nRv ~/.ssh
sudo ausearch -m AVC,USER_AVC -ts recent
```

`restorecon -n` shows what would change without applying it. Only after checking policy expectations should I relabel anything. I also need to test with the account whose keys are failing, not assume root's home represents every user.

Leaving this here because it's a useful example of a diagnosis I *had not proved*.
