# macOS.

# Homebrew. Apple Silicon uses /opt/homebrew, Intel /usr/local.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Prefer GNU coreutils when installed, so ls/sed/awk behave the same as on
# Linux. Without this, `ls --color=auto` is a syntax error on BSD ls.
if [[ -d "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/coreutils/libexec/gnubin" ]]; then
  path=("${HOMEBREW_PREFIX:-/opt/homebrew}/opt/coreutils/libexec/gnubin" $path)
  export PATH
  alias ls='ls --color=auto --group-directories-first'
else
  # BSD ls: -G is the colour flag and LSCOLORS is the palette variable.
  alias ls='ls -G'
  export LSCOLORS="CxGxDxDxBxegedabagacad"
fi

alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -1'

alias pbc='pbcopy'
alias pbp='pbpaste'

# Flush the DNS cache; needed often enough to be worth a name.
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
