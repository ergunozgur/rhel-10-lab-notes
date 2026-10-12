# Nice levels and the process that vanished before I killed it

I tested background jobs, `ps`, `pgrep`, `kill`, `nice`, `renice`, and `top`. A few `kill` commands returned `No such process` simply because the PID I was using was already gone. Once I checked the running processes again, the mystery disappeared.

For priority testing I started a `sleep` job with an explicit nice value, then used `renice` and checked it with `ps`:

```bash
nice -n 10 sleep 200 &
ps -eo pid,comm,ni,pri,etime,args | grep sleep
# use the *actual* PID returned above
renice +14 <pid>
```

I also tested higher-priority negative nice values as root on the VM. Changing a process's nice value is a scheduling hint, **not** a hard CPU quota, and `top`'s CPU percentage isn't proof the priority change improved anything.

For production I'd investigate what is actually consuming CPU, memory or I/O before changing priorities. `kill -9` was useful as an experiment, but graceful termination is normally preferable so services can clean up.
