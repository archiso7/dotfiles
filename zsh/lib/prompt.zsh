# Prompt: powerlevel10k, themed with the everforest palette.
#
# The old config also ran `precmd() { vcs_info }` with a vcs_info zstyle. That
# cost a measured 61ms on every single prompt, duplicating work powerlevel10k
# already does through its gitstatusd daemon — and the $vcs_info_msg_0_ it
# produced was referenced only from a PROMPT definition that was commented out.
# It is gone; p10k owns git status.
#
# everforest-dark.zsh defines the palette and feature set (purepower style).
# prompt-everforest.zsh layers the two-line ┌─/└─ layout on top. Both read
# POWERLEVEL9K_* variables, so they must be sourced after the theme itself.

source "${ZSH_CONFIG_DIR}/powerlevel10k/powerlevel10k.zsh-theme"
source "${ZSH_CONFIG_DIR}/everforest-dark.zsh"
source "${ZSH_CONFIG_DIR}/prompt-everforest.zsh"

# A hand-written ~/.p10k.zsh, if it ever exists, wins over the above.
[[ -f "${HOME}/.p10k.zsh" ]] && source "${HOME}/.p10k.zsh"
