# Shell options and history.
#
# The old config set several of these twice under both spellings — `autocd`
# and `AUTO_CD`, `auto_menu` and `AUTO_MENU` — because a zsh-newuser-install
# block at the top was never reconciled with a hand-written block at the
# bottom. Each option appears exactly once here.

# --- Directories -------------------------------------------------------------
setopt AUTO_CD              # bare directory name means cd
setopt AUTO_PUSHD           # cd pushes onto the directory stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# --- Globbing ----------------------------------------------------------------
setopt EXTENDED_GLOB
setopt NO_MATCH
setopt NO_NOMATCH           # leave unmatched globs alone instead of erroring

# --- History -----------------------------------------------------------------
# 1000 was the old limit, shared across every pane, against a history file
# already 75KB on disk. It churned constantly.
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY     # record timestamp and duration
setopt SHARE_HISTORY        # sync across running shells
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE    # a leading space keeps a command out of history
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY          # expand !! but let you confirm before running
setopt HIST_EXPIRE_DUPS_FIRST

# Migrate the old history file on first run of the new config.
if [[ -f "${HOME}/.histfile" && ! -f "$HISTFILE" ]]; then
  cp "${HOME}/.histfile" "$HISTFILE"
fi

# --- Job control / misc ------------------------------------------------------
setopt NOTIFY
setopt LONG_LIST_JOBS
setopt INTERACTIVE_COMMENTS # allow # comments when typing interactively
unsetopt BEEP
unsetopt FLOW_CONTROL       # free up ^S and ^Q

# CORRECT_ALL is deliberately absent. It second-guesses command *arguments*,
# including filenames, and is the single most commonly regretted zsh option.
setopt CORRECT

# --- Environment -------------------------------------------------------------
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R"
export CLICOLOR=1
