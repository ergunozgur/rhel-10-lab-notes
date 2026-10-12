# Podman pods: two containers listed, but only one was my application

I created a pod named `mypod` and ran Nginx inside it:

```console
# podman pod create --name mypod
# podman run -dt --name nginxserver --pod=mypod docker.io/library/nginx
# podman pod list
POD ID        NAME    STATUS     ...  # OF CONTAINERS
<id>          mypod   Running    ...  2
```

I was initially interested in why the pod listed **two containers** when I'd started only Nginx. `podman ps --pod` showed one Nginx container and one infrastructure container for the pod. That infrastructure container helps hold the shared namespace configuration.

I inspected the pod and confirmed the Nginx process was in it, then stopped and removed the test pod:

```bash
podman pod inspect mypod
podman ps --pod
podman exec -it nginxserver sh
podman pod stop mypod
podman pod rm mypod
```

A pod shares things such as a network namespace across its member containers; that's useful for closely coupled services, but it doesn't mean every pod should expose every port. Port publication should be planned when the pod is created.

For persistent services on an actual host, consider a [Quadlet-based deployment](../reference/podman-in-production.md) instead of relying solely on a detached lab container.
