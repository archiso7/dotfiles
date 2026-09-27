# Linux (Arch).

alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -1'

alias grep='grep --color=auto'
alias diff='diff --color=auto'

# pacman / AUR.
if (( $+commands[pacman] )); then
  alias pacs='sudo pacman -S'
  alias pacr='sudo pacman -Rns'
  alias pacu='sudo pacman -Syu'
  alias pacq='pacman -Qi'
  alias pacsearch='pacman -Ss'
  alias pacorphans='pacman -Qtdq'
fi
(( $+commands[paru] )) && alias aur='paru'
(( $+commands[yay] ))  && alias aur='yay'

# Clipboard. Wayland and X11 use different tools; expose one name for both so
# scripts and tmux config do not need to branch.
if (( $+commands[wl-copy] )); then
  alias pbc='wl-copy'
  alias pbp='wl-paste'
elif (( $+commands[xclip] )); then
  alias pbc='xclip -selection clipboard'
  alias pbp='xclip -selection clipboard -o'
fi

alias jctl='journalctl -xe'
alias sysu='systemctl --user'
