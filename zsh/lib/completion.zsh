# Completion.
#
# compinit was previously called unconditionally, which stats every file in
# fpath on every shell start. The guard below rebuilds the dump at most once a
# day and uses the cached form otherwise.
#
# `menu_complete` was also set, which inserts the first match immediately.
# fzf-tab needs the standard completion menu to hook into, so the two fight —
# this is why tab completion behaved inconsistently.

autoload -Uz compinit

_zcompdump="${HOME}/.zcompdump"
# (#qN.mh+24) = exists, plain file, modified more than 24 hours ago.
if [[ -n ${_zcompdump}(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
  # Recompile in the background; the .zwc is what makes the next start fast.
  { zcompile -R -- "${_zcompdump}.zwc" "$_zcompdump" } &!
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump

zmodload -i zsh/complist

setopt AUTO_LIST
setopt AUTO_MENU
setopt AUTO_PARAM_SLASH
setopt AUTO_PARAM_KEYS
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt LIST_PACKED
setopt LIST_ROWS_FIRST
unsetopt MENU_COMPLETE      # see note above: conflicts with fzf-tab

# --- Styles ------------------------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose true
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${HOME}/.cache/zsh/compcache"

# fzf-tab requires the built-in menu to be off rather than `menu select`.
zstyle ':completion:*' menu no

# --- fzf-tab -----------------------------------------------------------------
# Must load after compinit, since it replaces the completion widget.
source "${ZSH_CONFIG_DIR}/fzf-tab/fzf-tab.plugin.zsh"

zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath 2>/dev/null || ls -1 $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls -1 $realpath'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview 'ps -p $word -o comm='

# --- fzf shell integration ---------------------------------------------------
# This was never sourced before, so ^R history search and ^T file search did
# not exist — only fzf-tab's completion hook.
if (( $+commands[fzf] )); then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  fi
fi

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border=rounded --info=inline'
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
