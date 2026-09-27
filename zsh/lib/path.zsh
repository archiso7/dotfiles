# PATH construction.
#
# `typeset -U path` makes the array unique, so re-sourcing this file (or
# nested shells) cannot produce duplicate entries. The old config appended
# /home/archiso/.local/bin, a Linux path from a 2024 pipx install that never
# existed on macOS.

typeset -U path PATH

# Prepended in reverse priority order; earlier entries below end up first.
local -a candidates=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.cargo/bin"
)

for dir in $candidates; do
  [[ -d $dir ]] && path=("$dir" $path)
done
unset candidates dir

export PATH
