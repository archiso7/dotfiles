# Keybindings.
#
# vi mode makes Escape the mode switch, which races any binding whose sequence
# starts with \e (Alt). The old config bound \eh \et \en \es for
# tmux-sessionizer with no KEYTIMEOUT set, so those were intermittently
# swallowed by the mode switch. KEYTIMEOUT=1 (10ms) makes Escape snappy and
# leaves the Alt sequences readable.

bindkey -v
export KEYTIMEOUT=1

# --- History search ----------------------------------------------------------
# Up/Down and ^P/^N search using what has already been typed as a prefix.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey -M viins '^P' up-line-or-beginning-search
bindkey -M viins '^N' down-line-or-beginning-search
bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search

# --- Emacs-style essentials kept in insert mode ------------------------------
# Without these, vi insert mode loses line editing that muscle memory expects.
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^Y' yank
bindkey -M viins '^?' backward-delete-char   # keep backspace working
bindkey -M viins '^H' backward-delete-char

# --- Edit the current command line in $EDITOR --------------------------------
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# --- Completion menu navigation ----------------------------------------------
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect '^[' send-break

# --- tmux-sessionizer --------------------------------------------------------
# ^F opens the picker; Alt-h/t/n/s jump straight to a numbered session.
bindkey -s '^F' 'tmux-sessionizer\n'
bindkey -s '\eh' 'tmux-sessionizer -s 0\n'
bindkey -s '\et' 'tmux-sessionizer -s 1\n'
bindkey -s '\en' 'tmux-sessionizer -s 2\n'
bindkey -s '\es' 'tmux-sessionizer -s 3\n'

# --- Mode indicator ----------------------------------------------------------
# Block cursor in normal mode, beam in insert.
function zle-keymap-select {
  case $KEYMAP in
    vicmd) print -n '\e[2 q' ;;
    viins|main) print -n '\e[5 q' ;;
  esac
}
zle -N zle-keymap-select

function zle-line-init {
  print -n '\e[5 q'
}
zle -N zle-line-init

# Reset to a beam before running a command, so the cursor is not left blocky.
function preexec_cursor_reset { print -n '\e[5 q' }
autoload -Uz add-zsh-hook
add-zsh-hook preexec preexec_cursor_reset
