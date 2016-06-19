# Zsh for ADM

This is port of Zsh for Asustor ADM.

## Tips

To use Zsh whenevever you log in to your NAS over SSH, you can add modify/create the `.profile` in your home directory to launch Zsh whenever it detects an interactive login session.

Contents of `/$HOME/.profile`:

```shell
export TERM=xterm-256color

# check if zsh is accessible
if which zsh 2>&1 >/dev/null; then
	case $- in
		*i*) # interactive session
			exec zsh --login
			;;
	esac
fi
```
