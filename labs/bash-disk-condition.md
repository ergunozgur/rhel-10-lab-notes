# Bash: a condition that looked fine until I read it again

I was writing a script to warn about disk usage. It read the use percentage from `df`, stripped `%`, then used an `if` / `elif` / `else` chain.

The first condition worked in my lab, returning "Disk usage is under control." But in my notes the second test was written like this:

```bash
elif [ usage -lt 80 ]
```

That's missing the variable expansion (`$usage`). Since my first branch ran, it didn't prove the middle branch was correct. I shouldn't describe the whole script as tested just because one input happened to work.

A corrected and slightly safer version is:

```bash
usage=$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')

if (( usage < 50 )); then
  echo 'Disk usage is under control.'
elif (( usage < 80 )); then
  echo 'Disk usage is moderate.'
else
  echo 'Disk usage is critical!'
fi
```

This is also a good example of why it helps to test conditions across multiple values, rather than just one happy-path result. See [`../scripts/disk-usage-check.sh`](../scripts/disk-usage-check.sh) for an expanded version with a configurable threshold.
