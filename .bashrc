#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Drop in to fish only if the parent process is not fish
if hash fish 2>/dev/null && [[ $(ps --no-header --pid=$PPID --format=cmd) != "fish" ]]; then
	exec fish
fi

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'

alias cp='cp -iv --reflink=auto'
alias mv='mv -iv'
alias rm='rm -iv'

# Prompt
PS1='[\u@\h \W]\$ '
