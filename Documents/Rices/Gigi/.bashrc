#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias swaptheme='bash ~/Documents/Rices/swaptheme.sh'
alias passgpu='bash ./rtktop/gpu-passthrough.sh'

PS1='\[\e[0;33m\]\u\[\e[0m\]\[\e[0;31m\]♡\[\e[0m\]\[\e[38;5;208m\]\h\[\e[0m\]:\w\$ '

if [ -n "$DISPLAY" ] && command -v kitten &>/dev/null; then
    clear
    ( kitten icat --place=728x408@-323x0 ~/Pictures/Gigi/Gifs/GigiFetch.gif ) > /dev/tty

    sleep 0.4
fi

fastfetch

[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion
