# Podman wouldn't let me remove a volume

I created a named volume called `mydata`, attached it to a Fedora container called `myapp`, and then tried to delete the volume while the container still referenced it.

```console
# podman volume create mydata
mydata
# podman volume rm mydata
Error: volume mydata is being used by the following container(s): ... volume is being used
```

I checked which containers and volumes existed, then stopped **and removed the lab container** before retrying the volume deletion:

```console
# podman stop myapp
myapp
# podman rm myapp
myapp
# podman volume rm mydata
mydata
```

That worked in the disposable test. The lesson for a real system is almost the opposite: a volume often contains the important persistent data. Don't remove it just to make an error disappear. First inspect the container references and back up anything that matters:

```bash
podman volume inspect mydata
podman ps -a
podman inspect myapp
```

My earlier notes also contained a bind-mount experiment. If I come back to that on SELinux-enforcing systems, I'll need to check file ownership and suitable `:z` / `:Z` relabel options rather than reaching for `chmod 777`.
