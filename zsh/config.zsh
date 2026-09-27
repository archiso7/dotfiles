# Shell configuration entry point. Sourced from ~/.zshrc.
#
# Load order below is deliberate and mostly not reorderable:
#
#   path         before anything that probes for executables
#   options      before completion, since completion reads setopt state
#   completion   compinit must run before fzf-tab wraps the completion widget
#   keybinds     after completion, so widgets exist to bind
#   plugins      devt sources gitc itself; do not source gitc separately
#   prompt       powerlevel10k, then the everforest overrides it reads
#   highlight    fast-syntax-highlighting LAST; it wraps every ZLE widget
#                defined up to this point, so anything loaded after it is
#                not highlighted
#   os           per-platform, keyed on `uname -s`, plus os/wsl.zsh when the
#                kernel reports WSL
#   local        machine-specific and gitignored; overrides everything
#
# Native Windows does not run zsh at all; see windows/profile.ps1.

ZSH_CONFIG_DIR="${${(%):-%x}:A:h}"

source "$ZSH_CONFIG_DIR/lib/path.zsh"
source "$ZSH_CONFIG_DIR/lib/options.zsh"
source "$ZSH_CONFIG_DIR/lib/completion.zsh"
source "$ZSH_CONFIG_DIR/lib/keybinds.zsh"
source "$ZSH_CONFIG_DIR/lib/aliases.zsh"
source "$ZSH_CONFIG_DIR/lib/functions.zsh"

# devt wraps Shopify's `dev` with tmux sessions and sources gitc for its
# shared helpers. gitc was previously also sourced twice from this file, so it
# loaded three times per shell.
[[ -f "$ZSH_CONFIG_DIR/devt/devt.zsh" ]] && source "$ZSH_CONFIG_DIR/devt/devt.zsh"

source "$ZSH_CONFIG_DIR/lib/prompt.zsh"

source "$ZSH_CONFIG_DIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

_zsh_os_file="$ZSH_CONFIG_DIR/os/$(uname -s).zsh"
[[ -f "$_zsh_os_file" ]] && source "$_zsh_os_file"
unset _zsh_os_file

[[ -f "$ZSH_CONFIG_DIR/local.zsh" ]] && source "$ZSH_CONFIG_DIR/local.zsh"
