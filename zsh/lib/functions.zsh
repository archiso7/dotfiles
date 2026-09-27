# Shell functions.

# Switch to a sibling git worktree in place.
wt() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    print -u2 "wt: not inside a git repository"
    return 1
  fi
  if (( ! $+commands[fzf] )); then
    print -u2 "wt: fzf is required"
    return 1
  fi

  local selected
  selected=$(git worktree list | fzf --prompt='worktree> ' --height 40% | awk '{print $1}')
  [[ -n "$selected" ]] && cd "$selected"
}

# mkdir and cd in one step.
take() {
  mkdir -p "$1" && cd "$1"
}

# Up N directories: `up 3` is ../../..
up() {
  local levels="${1:-1}"
  local target=""
  for _ in {1..$levels}; do
    target="../$target"
  done
  cd "$target" || return 1
}

# Show what is listening on a port.
port() {
  if [[ -z "$1" ]]; then
    print -u2 "usage: port <number>"
    return 1
  fi
  lsof -nP -iTCP:"$1" -sTCP:LISTEN
}

# Extract most archive formats without remembering the flags.
extract() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    print -u2 "extract: '$file' is not a file"
    return 1
  fi
  case "$file" in
    *.tar.bz2) tar xjf "$file" ;;
    *.tar.gz)  tar xzf "$file" ;;
    *.tar.xz)  tar xJf "$file" ;;
    *.tar)     tar xf  "$file" ;;
    *.tbz2)    tar xjf "$file" ;;
    *.tgz)     tar xzf "$file" ;;
    *.bz2)     bunzip2 "$file" ;;
    *.gz)      gunzip  "$file" ;;
    *.zip)     unzip   "$file" ;;
    *.Z)       uncompress "$file" ;;
    *.7z)      7z x    "$file" ;;
    *)         print -u2 "extract: unknown archive type '$file'" ; return 1 ;;
  esac
}
