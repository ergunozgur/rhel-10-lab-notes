# Podman outside a disposable lab

I practised pulling images, creating and stopping containers, committing a changed container into an image, volumes and pod networking. The lab made the command syntax familiar. Running a real service needs more: data persistence, identities, logging, restart behavior, updates and policy.

## Inspect before touching data

```bash
podman ps -a
podman images
podman inspect <container>
podman logs --tail 100 <container>
podman volume ls
podman volume inspect <volume>
```

A stopped or failed container may still own volumes. Removing a container or volume can destroy useful state; if it contains a database, I want a deliberate backup rather than `podman rm -f` as my first troubleshooting step.

## Bind mounts and SELinux

For a dedicated lab directory, the `:Z` option can give a private SELinux label suitable for one container, while `:z` can be used for sharing among containers. **Both may relabel host content.** Never casually use them on broad or important system directories. Check user namespace and rootless file ownership as well.

## A service after reboot

RHEL 10 documentation describes **Quadlet** files (`.container`, `.volume`, `.pod` etc.) that systemd can turn into services. A simplified *reference-only* rootless container description might look like:

```ini
[Unit]
Description=Example rootless test web container

[Container]
Image=docker.io/library/nginx:stable
ContainerName=example-web
PublishPort=127.0.0.1:8080:80

[Service]
Restart=on-failure

[Install]
WantedBy=default.target
```

Store it as `~/.config/containers/systemd/example-web.container`, reload the **user** manager with `systemctl --user daemon-reload`, and inspect the generated `example-web.service`. This is a starting point, not a verified deployment from my original labs. Verify the image version, rootless port mapping, lifecycle and reboot persistence before relying on it.

If using a rootless service without interactive login, evaluate user lingering and organizational policy. Rootful and rootless unit locations aren't interchangeable.

Docs: [RHEL 10 managing containers](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/building_running_and_managing_containers/index).
