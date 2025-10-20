devt() {
  # Validate arguments
  if [[ $# -lt 2 ]]; then
    echo "Usage: devt {cd|clone} <arguments>"
    return 1
  fi
  
  if [[ "$1" != "cd" && "$1" != "clone" ]]; then
    echo "Error: First argument must be 'cd' or 'clone'"
    return 1
  fi
  
  local command="$1"
  shift
  local args="$@"
  
  # Determine session name
  if [[ "$command" == "clone" ]]; then
    local repo_name="${1##*/}"
    repo_name="${repo_name%.git}"
    local session_name="$repo_name"
  else
    # For cd, run it first to get directory
    local session_name="${1##*/}"
  fi
  
  # Create and attach to tmux session, running dev command inside
  tmux new-session -s "$session_name" -d
  tmux send-keys -t "$session_name" "dev $command $args" C-m
  tmux attach-session -t "$session_name"
}

devt-refresh-cache() {
  echo "Refreshing Shopify repos cache..."
  gh repo list devdegree --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner' > "${HOME}/.cache/devt-devdegree-repos"
  echo "Cache refreshed!"
}

_devt() {
  local -a subcommands
  subcommands=('cd:Change to a local repository' 'clone:Clone a repository')
  
  if [[ $CURRENT -eq 2 ]]; then
    _describe 'devt commands' subcommands
    return
  fi
  
  if [[ $CURRENT -eq 3 ]]; then
    case "$words[2]" in
      clone)
        local -a repos
        local cache_file="${HOME}/.cache/devt-devdegree-repos"
        local cache_time=3600
        
        mkdir -p "${HOME}/.cache"
        
        if [[ -f "$cache_file" ]] && [[ $(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null))) -lt $cache_time ]]; then
          repos=("${(@f)$(cat $cache_file)}")
        else
          # Get repos with Shopify/ prefix
          repos=("${(@f)$(gh repo list devdegree --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner' 2>/dev/null)}")
          if [[ ${#repos[@]} -gt 0 ]]; then
            printf '%s\n' "${repos[@]}" > "$cache_file"
          fi
        fi
        
        if [[ ${#repos[@]} -gt 0 ]]; then
          _describe 'Shopify repositories' repos
        else
          _message "Install gh CLI and run: gh auth login"
        fi
        ;;
      cd)
        local devdegree_dir="${HOME}/src/github.com/DevDegree"
        if [[ -d "$devdegree_dir" ]]; then
          local -a local_repos
          local_repos=("${(@f)$(ls -1 $devdegree_dir 2>/dev/null)}")
          _describe 'local repositories' local_repos
        fi
        ;;
    esac
  fi
}

compdef _devt devt
