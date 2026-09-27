# Fresh native-Windows setup.
#
#   irm https://raw.githubusercontent.com/archiso7/dotfiles/main/windows/bootstrap.ps1 | iex
#
# or, from an existing checkout:
#
#   pwsh -ExecutionPolicy Bypass -File $HOME\.config\windows\bootstrap.ps1
#
# Idempotent: re-running skips anything already present.

#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$SkipPackages
)

$ErrorActionPreference = 'Stop'
$DotfilesRoot = Join-Path $HOME '.config'
$RepoUrl = 'https://github.com/archiso7/dotfiles'

function Write-Step { param($m) Write-Host "==> $m" -ForegroundColor Green }
function Write-Skip { param($m) Write-Host "    $m" -ForegroundColor DarkGray }

# --- Packages ----------------------------------------------------------------
if (-not $SkipPackages) {
    Write-Step 'Installing packages via winget'

    if (-not (Get-Command winget -ErrorAction Ignore)) {
        throw 'winget not found. Install "App Installer" from the Microsoft Store first.'
    }

    # neovim 0.11+ is required; the config uses vim.lsp.config and vim.hl.
    $packages = @(
        'Neovim.Neovim',
        'Git.Git',
        'junegunn.fzf',
        'BurntSushi.ripgrep.MSVC',
        'sharkdp.fd',
        'JesseDuffield.lazygit',
        'Microsoft.PowerShell',
        'ajeetdsouza.zoxide'
    )

    foreach ($pkg in $packages) {
        $installed = winget list --id $pkg --exact 2>$null | Select-String $pkg
        if ($installed) {
            Write-Skip "$pkg already installed"
        } else {
            Write-Host "    installing $pkg"
            winget install --id $pkg --exact --silent `
                --accept-package-agreements --accept-source-agreements
        }
    }

    Write-Step 'Installing PowerShell modules'
    foreach ($mod in @('PSReadLine', 'PSFzf')) {
        if (Get-Module -ListAvailable -Name $mod) {
            Write-Skip "$mod already installed"
        } else {
            Install-Module $mod -Scope CurrentUser -Force -AllowClobber -AllowPrerelease:$false
        }
    }
}

# --- Repository --------------------------------------------------------------
Write-Step 'Setting up the dotfiles checkout'
if (Test-Path (Join-Path $DotfilesRoot '.git')) {
    Write-Skip "$DotfilesRoot already a git repo"
} else {
    git clone --recurse-submodules $RepoUrl $DotfilesRoot
}

Write-Step 'Applying the windows sparse-checkout profile'
Push-Location $DotfilesRoot
try {
    git config core.sparseCheckout true
    $sparse = Join-Path $DotfilesRoot '.git\info\sparse-checkout'
    # Native Windows can use nvim/ and windows/; zsh, tmux, and the Wayland
    # desktop configs are not applicable.
    @('/*', '!/*/', '/nvim/', '/windows/') | Set-Content -Path $sparse -Encoding ascii
    git read-tree -mu HEAD
    git config dotfiles.profile 'windows'
} finally {
    Pop-Location
}

# --- Profile -----------------------------------------------------------------
Write-Step 'Linking the PowerShell profile'
$profileTarget = Join-Path $DotfilesRoot 'windows\profile.ps1'
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
}
if ((Test-Path $PROFILE) -and -not (Get-Item $PROFILE).LinkType) {
    $backup = "$PROFILE.pre-dotfiles.bak"
    Write-Host "    backing up existing profile to $backup"
    Move-Item $PROFILE $backup -Force
}
New-Item -ItemType SymbolicLink -Path $PROFILE -Target $profileTarget -Force | Out-Null

# --- neovim config -----------------------------------------------------------
# nvim honours XDG_CONFIG_HOME, which profile.ps1 sets to ~/.config. A junction
# at the default location covers invocations that do not inherit the profile
# (scheduled tasks, other terminals, GUI launchers).
Write-Step 'Linking the neovim config'
$nvimDefault = Join-Path $env:LOCALAPPDATA 'nvim'
$nvimSource = Join-Path $DotfilesRoot 'nvim'
if (Test-Path $nvimDefault) {
    $item = Get-Item $nvimDefault -Force
    if ($item.LinkType) {
        Write-Skip 'already linked'
    } else {
        $backup = "$nvimDefault.pre-dotfiles.bak"
        Write-Host "    backing up existing config to $backup"
        Move-Item $nvimDefault $backup -Force
        New-Item -ItemType Junction -Path $nvimDefault -Target $nvimSource | Out-Null
    }
} else {
    New-Item -ItemType Junction -Path $nvimDefault -Target $nvimSource | Out-Null
}

# --- Machine-local profile ---------------------------------------------------
$localPs1 = Join-Path $DotfilesRoot 'windows\local.ps1'
if (-not (Test-Path $localPs1)) {
    Write-Step 'Creating windows/local.ps1'
    @(
        '# Machine-specific PowerShell config. Gitignored.',
        '# Sourced last by profile.ps1, so it overrides everything.',
        ''
    ) | Set-Content -Path $localPs1 -Encoding utf8
}

Write-Host ''
Write-Step 'Done'
Write-Host '    Restart PowerShell, then launch nvim once to install plugins.'
Write-Host '    Symlink creation needs Developer Mode or an elevated shell.'
