# WSL. Sourced in addition to os/Linux.zsh, since `uname -s` reports Linux.
#
# Detection happens in config.zsh. WSL differs from bare Linux in three ways
# that matter: the clipboard lives on the Windows side, opening a URL has to
# cross the boundary, and interop appends the entire Windows PATH.

# --- Windows PATH pollution --------------------------------------------------
# Interop appends every Windows PATH entry, often 30+ directories on network
# or OneDrive-backed paths. Command completion then stats all of them and
# crawls. Keep only the entries actually worth calling from Linux.
#
# The permanent fix is appendWindowsPath=false in /etc/wsl.conf; this is the
# fallback for machines where that has not been set.
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  typeset -a _keep_win
  _keep_win=()
  for _p in $path; do
    case "$_p" in
      /mnt/c/*)
        # Keep only things worth invoking from the Linux side.
        case "$_p" in
          */System32|*/System32/*|*/WindowsApps|*/Microsoft\ VS\ Code/bin)
            _keep_win+=("$_p") ;;
        esac
        ;;
      *) _keep_win+=("$_p") ;;
    esac
  done
  path=($_keep_win)
  export PATH
  unset _keep_win _p
fi

# --- Clipboard ---------------------------------------------------------------
# win32yank handles both directions and is what neovim prefers; clip.exe plus
# a PowerShell read is the no-install fallback.
if (( $+commands[win32yank.exe] )); then
  alias pbc='win32yank.exe -i --crlf'
  alias pbp='win32yank.exe -o --lf'
elif (( $+commands[clip.exe] )); then
  alias pbc='clip.exe'
  alias pbp='powershell.exe -NoProfile -Command Get-Clipboard | tr -d "\r"'
fi

# --- Opening things ----------------------------------------------------------
if (( $+commands[wslview] )); then
  export BROWSER=wslview
  alias open='wslview'
elif (( $+commands[explorer.exe] )); then
  # explorer.exe returns nonzero even on success, hence the `|| true`.
  open() { explorer.exe "$(wslpath -w "${1:-.}")" || true }
fi

# --- Interop helpers ---------------------------------------------------------
# Jump to the Windows user profile.
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  _win_user="$(powershell.exe -NoProfile -Command '$env:USERNAME' 2>/dev/null | tr -d '\r')"
  if [[ -n "$_win_user" && -d "/mnt/c/Users/$_win_user" ]]; then
    export WINHOME="/mnt/c/Users/$_win_user"
    alias cdwin='cd "$WINHOME"'
  fi
  unset _win_user
fi

# Docker Desktop's WSL integration exposes the socket here.
[[ -S /var/run/docker.sock ]] && export DOCKER_HOST="unix:///var/run/docker.sock"
