# Lines configured by zsh-newuser-install
autoload -Uz compinit
compinit
source ~/.config/zsh/fzf-tab/fzf-tab.plugin.zsh
source ~/.config/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source ~/.config/zsh/powerlevel10k/powerlevel10k.zsh-theme
source ~/.config/zsh/everforest-dark.zsh
source ~/.config/zsh/prompt-everforest.zsh
source ~/.config/zsh/gitc/gitc.zsh

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch notify
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install

alias ls='ls --color=auto'
alias ":q"="exit"


setopt auto_menu auto_param_keys auto_param_slash auto_remove_slash complete_in_word list_packed menu_complete list_rows_first

export CLICOLOR=1
export LSCOLORS="CxGxDxDxBxegedabagacad"
 
# Git branch detection
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{83}(%b)%f'
zstyle ':vcs_info:*' enable git

# Colorful prompt with git branch
setopt PROMPT_SUBST
 
# Define colors (Everforest Dark Hard RGB values)
local user_color='%F{#a7c080}'      # Green (#a7c080)
local host_color='%F{#83c092}'      # Aqua (#83c092)  
local path_color='%F{#e69875}'      # Orange (#e69875)
local git_color='%F{#dbbc7f}'       # Yellow (#dbbc7f)
local prompt_color='%F{#d3c6aa}'    # Foreground (#d3c6aa)
local bracket_color='%F{#859289}'   # Gray (#859289)
 
# Enhanced prompt
#PROMPT="${bracket_color}┌─[${user_color}%n${bracket_color}@${host_color}%m${bracket_color}]─[${path_color}%~${bracket_color}]${git_color}\$vcs_info_msg_0_
#${bracket_color}└─${prompt_color}$ %f"
 
# Right-side prompt with timestamp
#RPROMPT='%F{102}[%D{%H:%M:%S}]%f'
 
# Additional zsh options for better experience
setopt AUTO_CD              # cd by typing directory name if it's not a command
setopt CORRECT             # command auto-correction
setopt CORRECT_ALL         # argument auto-correction
setopt AUTO_LIST           # automatically list choices on ambiguous completion
setopt AUTO_MENU           # automatically use menu completion
setopt ALWAYS_TO_END       # move cursor to end if word had one match
setopt HIST_VERIFY         # show command with history expansion to user before running it
setopt SHARE_HISTORY       # share command history data
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Created by `pipx` on 2024-11-09 02:11:08
export PATH="$PATH:/home/archiso/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

#tmux-sessionizer
bindkey -s '^f' "tmux-sessionizer\n"
bindkey -s '\eh' "tmux-sessionizer -s 0\n"
bindkey -s '\et' "tmux-sessionizer -s 1\n"
bindkey -s '\en' "tmux-sessionizer -s 2\n"
bindkey -s '\es' "tmux-sessionizer -s 3\n"

# Load gitc and devt
source ~/.config/zsh/gitc/gitc.zsh
source ~/.config/zsh/devt/devt.zsh
