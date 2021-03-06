# ncurses for ADM

This is port of ncurses for Asustor ADM.

## About ncurses

The ncurses (new curses) library is a free software emulation of curses in System V Release 4.0 (SVr4), and more. It uses terminfo format, supports pads and color and multiple highlights and forms characters and function-key mapping, and has all the other SVr4-curses enhancements over BSD curses. SVr4 curses is better known today as X/Open Curses.

## Tips

If you wish to use this version of ncurses instead of the built-in busybox version, consider adding the executables to your path:

```
export PATH=/usr/local/AppCentral/ncurses/usr/bin:$PATH
export TERMINFO=/usr/local/AppCentral/ncurses/usr/share/terminfo
```

PS. The `TERMINFO` export is not necessary if you're using Zsh.
