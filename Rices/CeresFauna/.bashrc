#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
if [ -n "$DISPLAY" ] && command -v kitten &>/dev/null; then
    clear
    ( kitten icat --place=728x408@-323x0 ~/Pictures/FaunaFetch.gif ) > /dev/tty

    sleep 0.3
fi

fastfetch

[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

