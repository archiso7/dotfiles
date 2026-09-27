# Aliases.
#
# Anything whose flags differ between BSD and GNU userland lives in
# os/Darwin.zsh or os/Linux.zsh instead. The old config hardcoded
# `ls --color=auto`, which is GNU-only and worked on the Mac purely because
# Homebrew coreutils happened to be installed.

alias ':q'='exit'
alias ':wq'='exit'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'

# Interactive by default for the destructive three.
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias g='git'
alias gst='git status --short --branch'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gco='git checkout'
alias gb='git branch'
alias gp='git push'
alias gpl='git pull'

alias v='nvim'
alias vi='nvim'
alias vim='nvim'

alias tm='tmux'
alias tma='tmux attach'
alias tml='tmux list-sessions'

alias lg='lazygit'

# Reload the shell after editing config.
alias reload='exec zsh'
