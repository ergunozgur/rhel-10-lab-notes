# 10. Containers

Podman images, running services, named volumes, bind mounts, pods and the container lifecycle. This was all done as simple local VM exercises.

> Original lab notebook: approximately lines 3761–4267. The examples below are selected from my recorded work. Personal usernames, local addresses and lengthy console output have been shortened or replaced with examples.

## From my lab notebook

These are selected commands and observations from my actual RHEL 10 VM, in roughly the order I worked through them. I kept failures where they helped explain what happened. An absent error message is not proof of every possible test passing.

### configuring podman installation

```console
# podman --version
podman version 5.8.2
```

```console
# podman run hello-world
Resolved "hello-world" as an alias (/etc/containers/registries.conf.d/000-shortnames.conf)
Trying to pull quay.io/podman/hello:latest...
Getting image source signatures
```

### check the podman images currently available on our system

```console
# podman images
REPOSITORY            TAG         IMAGE ID      CREATED      SIZE
quay.io/podman/hello  latest      5dd467fce50b  2 years ago  787 kB
```

```console
# podman search --filter=is-official=true nginx
NAME                     DESCRIPTION
docker.io/library/nginx  Official build of Nginx.
```

### we will pull a specific version of nginx

```console
# podman pull nginx:1.21
Resolved "nginx" as an alias (/etc/containers/registries.conf.d/000-shortnames.conf)
Trying to pull docker.io/library/nginx:1.21...
Getting image source signatures
```

### implementing running containers

```console
# podman run 5253dc86cc93
# lets run the container in detached mode (runs in background)
```

```console
# podman run -d 5253dc86cc93
[redacted-id]
```

```console
# podman container list
CONTAINER ID  IMAGE                           COMMAND               CREATED             STATUS             PORTS       NAMES
7cd2c9905e8a  docker.io/library/nginx:latest  nginx -g daemon o...  About a minute ago  Up About a minute  80/tcp      elastic_jemison
39efc7b70741  docker.io/library/nginx:latest  nginx -g daemon o...  21 seconds ago      Up 21 seconds      80/tcp      myweb
```

```console
# podman run -d -p 8082:80 5253dc86cc93
[redacted-id]
type
http://localhost:8082
```

### run a container with an auto-restart Policy

```console
# podman run -d --restart=always --name myweb 5253dc86cc93
```

```console
# podman rm myweb
myweb
```

### creating and managing container images

```console
# podman run -it --name testcontainer fedora /bin/bash
Resolved "fedora" as an alias (/etc/containers/registries.conf.d/000-shortnames.conf)
Trying to pull registry.fedoraproject.org/fedora:latest...
Getting image source signatures
```

```console
# podman commit testcontainer myimage:v1
Getting image source signatures
Copying blob 095b56a8a9d8 skipped: already exists
Copying blob 449894565f13 done   |
```

```console
# podman run -it --name myapp -v mydata:/data fedora
[root@ddb3a1cc0bc3 /]#
[root@ddb3a1cc0bc3 ~]# touch /test.txt
[root@ddb3a1cc0bc3 ~]# ls
```

### create the directory

```console
# mkdir -p /home/student/mydir
```

```console
# podman run -it -v /home/student/mydir:/app fedora
[root@10b42de980f1 /]#
```

```console
# podman volume inspect mydata
[
{
"Name": "mydata",
```

### remove the volume

```console
# podman volume rm mydata
Error: volume mydata is being used by the following container(s): [redacted-id]: volume is being used
```

### stop the container first

```console
# podman stop myapp
myapp
```

```console
# podman pod create --name mypod
[redacted-id]
```

```console
# podman run -dt --name nginxserver --pod=mypod docker.io/library/nginx
[redacted-id]
```

```console
# podman pod list
POD ID        NAME        STATUS      CREATED            INFRA ID      # OF CONTAINERS
7c4befa28607  mypod       Running     About an hour ago  d72b42e7f7ae  2
```

```console
# podman ps --pod
CONTAINER ID  IMAGE                           COMMAND               CREATED            STATUS            PORTS       NAMES               POD ID        PODNAME
d72b42e7f7ae                                                        About an hour ago  Up About an hour              7c4befa28607-infra  7c4befa28607  mypod
884045c80dc2  docker.io/library/nginx:latest  nginx -g daemon o...  About an hour ago  Up About an hour  80/tcp      nginxserver         7c4befa28607  mypod
```

### access a container running inside the pod

```console
# podman exec -it nginxserver sh
# ls
bin   docker-entrypoint.d   home   media  proc  sbin  tmp
boot  docker-entrypoint.sh  lib    mnt    root  srv   usr
```

### stop and remove the pod

```console
# podman pod stop mypod
mypod
```

```console
# podman pod rm -f mypod
```

## More useful details and commands

These are **additional reference notes** inspired by the RHEL 9 study guide and checked against relevant RHEL 10 documentation. They are not automatically claims that I ran these exact commands in my VM.

### Useful Podman operations beyond `run`

```bash
podman ps -a
podman images
podman inspect myweb
podman logs --tail 50 myweb
podman exec -it myweb sh
podman volume ls
podman pod ps
podman system df
```

A container image is not durable application data. Named volumes and host-mounted directories are separate resources and need their own backup strategy. Removing a container doesn't necessarily remove its named volume, and Podman refuses volume deletion while it is still attached.

For an always-on host I would investigate **systemd Quadlet** instead of relying only on an interactive `podman run --restart=always` command. Quadlet is an extra reference from the RHEL 10 documentation, not a lab I've claimed to run. See [containers in production](../reference/podman-in-production.md).

## Related lab write-ups

- [Podman volume in use](../labs/podman-volume-in-use.md)
- [Podman pods](../labs/podman-pods.md)

## Source and version notes

- The accompanying *RHCSA Red Hat Enterprise Linux 9 Certification Study Guide*, 8th edition (Michael Jang and Alessandro Orsaria), was used for reference on **10: An Introduction to Containers**. It is a RHEL 9 book; I did the practical work on RHEL 10.
- [Official RHEL 10 documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/building_running_and_managing_containers/porting-containers-to-systemd-using-podman) was used to cross-check the additional procedures.
- Commands against production disks, networking, SSH and access controls require local verification, backup and an access-recovery plan.
