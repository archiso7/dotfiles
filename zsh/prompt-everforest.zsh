# Everforest-styled prompt layout tweaks layered on top of powerlevel10k.
# This keeps colors and features defined by `everforest-dark.zsh` while
# adjusting the layout to resemble the commented prompt style in `config.zsh`.

if test -z "${ZSH_VERSION}"; then
  return 0
fi

() {
  emulate -L zsh && setopt no_unset pipe_fail

  # Keep the same elements/features but format to match:
  # ┌─[user@host]─[~]
  # └─$
  # Left shows: user@host (context) and current directory. Keep git for repos.
  typeset -ga POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
      context dir vcs)

  # Right shows: time of day and how long last command took, plus status/bg jobs.
  typeset -ga POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
      time command_execution_time status background_jobs)

  # Multi-line lead symbols.
  if [[ "${DESERT_NIGHT_PURE_POWER_TRUE_COLOR}" == "true" ]]; then
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%F{#859289}┌─%f'
    typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{#859289}└─%f$ '
  else
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%F{246}┌─%f'
    typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{246}└─%f$ '
  fi

  # Two-line prompt, right prompt stays on the first line.
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  typeset -g POWERLEVEL9K_RPROMPT_ON_NEWLINE=false

  # Compact separators on the left to honor exact outline; readable spacing on right.
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS=
  typeset -g POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS=' · '

  # Bracket the context and directory segments and connect them with "─".
  # [user@host]─[dir]
  typeset -g POWERLEVEL9K_CONTEXT_PREFIX='['
  typeset -g POWERLEVEL9K_CONTEXT_SUFFIX=']'
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'

  typeset -g POWERLEVEL9K_DIR_PREFIX=$'─['
  typeset -g POWERLEVEL9K_DIR_SUFFIX=']'

  # Bracket VCS and connect with a thin separator to improve readability.
  typeset -g POWERLEVEL9K_VCS_PREFIX=$'─['
  typeset -g POWERLEVEL9K_VCS_SUFFIX=']'

  # Enhanced & compact VCS content. Hide zeros and avoid extra spaces between counters.
  # Example: "main⇡2⇣1+3~1…2≡1" (only non-zero parts shown)
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${VCS_STATUS_LOCAL_BRANCH}${VCS_STATUS_TAG:+@${VCS_STATUS_TAG}}${${VCS_STATUS_COMMITS_AHEAD:#0}:+⇡${VCS_STATUS_COMMITS_AHEAD}}${${VCS_STATUS_COMMITS_BEHIND:#0}:+⇣${VCS_STATUS_COMMITS_BEHIND}}${${VCS_STATUS_NUM_STAGED:#0}:++${VCS_STATUS_NUM_STAGED}}${${VCS_STATUS_NUM_UNSTAGED:#0}:+~${VCS_STATUS_NUM_UNSTAGED}}${${VCS_STATUS_NUM_UNTRACKED:#0}:+?${VCS_STATUS_NUM_UNTRACKED}}${${VCS_STATUS_NUM_STASHES:#0}:+≡${VCS_STATUS_NUM_STASHES}}'

  # Ensure context (user@host) is visible locally.
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,ROOT,REMOTE_SUDO,REMOTE,SUDO}_BACKGROUND=none

  # Time on the right: HH:MM:SS with Everforest gray.
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=none
  typeset -g POWERLEVEL9K_TIME_ICON=
  typeset -g POWERLEVEL9K_TIME_PREFIX='['
  typeset -g POWERLEVEL9K_TIME_SUFFIX=']'
  if [[ "${DESERT_NIGHT_PURE_POWER_TRUE_COLOR}" == "true" ]]; then
    typeset -g POWERLEVEL9K_TIME_FOREGROUND='#859289'
  else
    typeset -g POWERLEVEL9K_TIME_FOREGROUND=246
  fi
  # Bracket command duration as well for consistency on the right side.
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX='['
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_SUFFIX=']'
} "$@"


