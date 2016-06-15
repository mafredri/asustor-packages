# Coreutils for ADM

This is port of Coreutils for Asustor ADM.

## Coreutils - GNU core utilities

Standard GNU file utilities (chmod, cp, dd, dir, ls...), text utilities (sort, tr, head, wc..), and shell utilities (whoami, who,...)

In this release all commands are prefixed with g, (gchmod, gcp, gdd, gdir, gls...) so that they do not conflict with the system binaries. To use them as the defaults in your shell, you can add the gnubin to your path like so:

```
PATH=/usr/local/AppCentral/coreutils/libexec/gnubin:$PATH
```

**Warning:** Be careful not to do this system-wide, it might cause scripts to fail in unexpected ways.
