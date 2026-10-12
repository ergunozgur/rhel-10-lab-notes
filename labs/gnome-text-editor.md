# `gedit` was missing, but the replacement was already installed

While going through the GUI editor exercises, I tried installing `gedit` on RHEL 10:

```console
# dnf install gedit
No match for argument: gedit
Error: Unable to find a match: gedit
```

I searched for alternatives:

```console
# dnf search gnome-text-editor
Name Exactly Matched: gnome-text-editor
```

`gnome-text-editor` was already installed, but trying to launch it from my root SSH session gave `Failed to open display`. That made sense once I remembered I wasn't in a graphical desktop session with a usable display.

For editing configuration files over SSH, `nano` or `vim` was simpler anyway. I don't need to install a desktop just to change a text file.
