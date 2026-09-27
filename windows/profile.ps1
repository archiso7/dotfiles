# PowerShell profile — native Windows.
#
# Install with windows/bootstrap.ps1, or link by hand:
#   New-Item -ItemType SymbolicLink -Path $PROFILE `
#     -Target "$HOME\.config\windows\profile.ps1" -Force
#
# This is the native-Windows counterpart to zsh/config.zsh. It deliberately
# mirrors the same keybindings, aliases, and functions so muscle memory carries
# across machines. It does NOT try to be zsh — where PowerShell has a better
# native answer (Get-ChildItem over ls), the alias wraps it.
#
# WSL uses zsh/ instead; nothing here applies there.
#
# Machine-specific settings go in windows/local.ps1 (gitignored), sourced last.

$DotfilesRoot = Join-Path $HOME '.config'

# --- Modules -----------------------------------------------------------------
# PSReadLine ships with PowerShell 7 but is often outdated on 5.1.
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -ViModeIndicator Cursor
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -MaximumHistoryCount 100000

    # Prefix-based history search on Up/Down, matching zsh's
    # up-line-or-beginning-search.
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # Emacs-style essentials kept in insert mode, same as keybinds.zsh.
    Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
    Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine
    Set-PSReadLineKeyHandler -Key Ctrl+k -Function KillLine
    Set-PSReadLineKeyHandler -Key Ctrl+u -Function BackwardDeleteLine
    Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardKillWord
    Set-PSReadLineKeyHandler -Key Ctrl+p -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key Ctrl+n -Function HistorySearchForward
}

# fzf-based history and file search, the closest thing to fzf-tab.
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' `
                    -PSReadlineChordReverseHistory 'Ctrl+r'
}

# --- Environment -------------------------------------------------------------
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'

# nvim reads $XDG_CONFIG_HOME/nvim when set, which lets the same ~/.config
# checkout serve Windows without a second copy or a junction.
$env:XDG_CONFIG_HOME = $DotfilesRoot
$env:XDG_DATA_HOME   = Join-Path $HOME '.local\share'
$env:XDG_STATE_HOME  = Join-Path $HOME '.local\state'
$env:XDG_CACHE_HOME  = Join-Path $HOME '.cache'

if (Get-Command fd -ErrorAction Ignore) {
    $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
}
$env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border=rounded --info=inline'

# --- Aliases -----------------------------------------------------------------
# Remove the built-ins that shadow real tools before redefining them.
foreach ($a in 'ls', 'cat', 'rm', 'mv', 'cp', 'man', 'where') {
    if (Test-Path "Alias:$a") { Remove-Item "Alias:$a" -Force -ErrorAction SilentlyContinue }
}

function ll { Get-ChildItem @args | Format-Table -AutoSize }
function la { Get-ChildItem -Force @args | Format-Table -AutoSize }
function l  { Get-ChildItem -Name @args }
function ls { Get-ChildItem @args }

Set-Alias v    nvim
Set-Alias vi   nvim
Set-Alias vim  nvim
Set-Alias g    git
Set-Alias lg   lazygit
Set-Alias which Get-Command

function gst  { git status --short --branch @args }
function gd   { git diff @args }
function gds  { git diff --staged @args }
function gl   { git log --oneline --graph --decorate -20 @args }
function gco  { git checkout @args }
function gb   { git branch @args }
function gp   { git push @args }
function gpl  { git pull @args }

function .. { Set-Location .. }
function ... { Set-Location ../.. }

function reload { . $PROFILE }

# --- Functions (mirroring zsh/lib/functions.zsh) -----------------------------

# Switch to a sibling git worktree.
function wt {
    if (-not (git rev-parse --git-dir 2>$null)) {
        Write-Error 'wt: not inside a git repository'
        return
    }
    if (-not (Get-Command fzf -ErrorAction Ignore)) {
        Write-Error 'wt: fzf is required'
        return
    }
    $selected = git worktree list | fzf --prompt 'worktree> ' --height 40%
    if ($selected) {
        Set-Location ($selected -split '\s+')[0]
    }
}

# mkdir and cd in one step.
function take {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    Set-Location $Path
}

# Up N directories.
function up {
    param([int]$Levels = 1)
    Set-Location (('..\' * $Levels).TrimEnd('\'))
}

# Show what is listening on a port.
function port {
    param([Parameter(Mandatory)][int]$Number)
    Get-NetTCPConnection -LocalPort $Number -State Listen -ErrorAction SilentlyContinue |
        Select-Object LocalAddress, LocalPort, State, OwningProcess,
            @{ n = 'Process'; e = { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName } }
}

# --- Prompt ------------------------------------------------------------------
# oh-my-posh if present, otherwise a built-in that mirrors the zsh layout:
#   ┌─[user@host]─[path] (branch)
#   └─$
if (Get-Command oh-my-posh -ErrorAction Ignore) {
    $themeFile = Join-Path $DotfilesRoot 'windows\everforest.omp.json'
    if (Test-Path $themeFile) {
        oh-my-posh init pwsh --config $themeFile | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
} else {
    function prompt {
        $fgGrey   = "`e[38;2;133;146;137m"
        $fgGreen  = "`e[38;2;167;192;128m"
        $fgAqua   = "`e[38;2;131;192;146m"
        $fgOrange = "`e[38;2;230;152;117m"
        $fgYellow = "`e[38;2;219;188;127m"
        $reset    = "`e[0m"

        $path = $ExecutionContext.SessionState.Path.CurrentLocation.Path.Replace($HOME, '~')

        # USERNAME/COMPUTERNAME are Windows-only; fall back so the prompt is
        # never rendered with empty brackets.
        $who = if ($env:USERNAME) { $env:USERNAME } else { [Environment]::UserName }
        $host_ = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { [Environment]::MachineName }

        $branch = ''
        $ref = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -eq 0 -and $ref) {
            $branch = "$fgGrey─$reset$fgYellow($ref)$reset"
        }

        $line1 = "$fgGrey┌─[$reset$fgGreen$who$reset$fgGrey@$reset$fgAqua$host_$reset$fgGrey]─[$reset$fgOrange$path$reset$fgGrey]$reset$branch"
        $line2 = "$fgGrey└─$reset$ "

        "$line1`n$line2"
    }
}

# --- Machine-specific --------------------------------------------------------
$localProfile = Join-Path $DotfilesRoot 'windows\local.ps1'
if (Test-Path $localProfile) { . $localProfile }
