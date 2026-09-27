# dotfiles

`~/.config` is the git repository itself. There is no symlink farm and no stow
— files live where the application expects them. Two exceptions, both forced by
tools that will not read from `~/.config`: `~/.zshrc` symlinks to `zsh/zshrc`,
and on native Windows `$PROFILE` symlinks to `windows/profile.ps1` with a
junction at `%LOCALAPPDATA%\nvim`.

Four machines share this repo:

| Machine | OS | Profile | Shell |
| --- | --- | --- | --- |
| work laptop | macOS | `macos` | zsh |
| personal laptop | Arch + Hyprland | `arch` | zsh |
| desktop (WSL) | Ubuntu under WSL2 | `wsl` | zsh |
| desktop (native) | Windows | `windows` | PowerShell |

## Two mechanisms keep this portable

Read this section before editing anything. Both are invisible until they bite.

### 1. Sparse-checkout profiles

`core.sparseCheckout` is enabled. Each machine materialises only the
directories it can use — the Arch desktop configs are tracked in the index with
`skip-worktree` bits on the other machines, which is why they neither appear on
disk nor show as deleted in `git status`.

```sh
bin/dotfiles-profile              # show active / detected / available
bin/dotfiles-profile --detect     # apply the right one for this machine
bin/dotfiles-profile arch         # apply a specific profile
```

Profiles are plain directory lists in `profiles/`. The active name is recorded
in `git config dotfiles.profile`, because several profiles share the same
directory list and the name cannot be inferred from the sparse patterns alone.

If you add a new top-level directory, add it to the relevant profile *and*
whitelist it in `.gitignore` (see below), or it will silently never appear.

### 2. Allowlist `.gitignore`

`.gitignore` ignores `*` and then re-includes specific paths. This is
deliberate: `~/.config` is full of machine-generated and work-only state
(`dev/`, `gcloud/`, `psst/`, `shopify-ai-dev/`, …) that must never be
committed, and an allowlist means new tooling defaults to *not* tracked.

To track a new directory you need both lines:

```gitignore
!/foo/
!/foo/**
```

## The three-layer rule

Every config splits into three layers. Put new settings in the narrowest layer
that works.

| Layer | Tracked | Applies to | Example |
| --- | --- | --- | --- |
| core | yes | every machine | `zsh/lib/options.zsh` |
| os | yes | one platform | `zsh/os/Darwin.zsh` |
| local | **no** | one machine | `zsh/local.zsh` |

The local layer is gitignored and always loads last, so it wins. That is where
work toolchains, private paths, and per-host quirks belong. Three exist:

```sh
cp zsh/local.zsh.example      zsh/local.zsh
cp tmux/local.conf.example    tmux/local.conf
# windows/local.ps1 is created by windows/bootstrap.ps1
```

## Layout

```
.config/
├── bin/dotfiles-profile     sparse-checkout profile switcher
├── profiles/                one file per machine type
├── nvim/                    submodule -> github.com/archiso7/nvim
├── zsh/                     shell (macOS, Arch, WSL)
├── tmux/
├── tmux-sessionizer/
├── windows/                 PowerShell profile + bootstrap (native Windows)
├── hypr/  waybar/  wofi/  kitty/     Arch desktop only
```

## zsh

```
zsh/
├── zshrc                 template for ~/.zshrc (symlinked)
├── config.zsh            orchestrator — documents and enforces load order
├── lib/
│   ├── path.zsh          PATH, deduped via typeset -U
│   ├── options.zsh       setopt + history
│   ├── completion.zsh    compinit (cached), fzf-tab, fzf integration
│   ├── keybinds.zsh      vi mode, history search, sessionizer
│   ├── aliases.zsh       platform-neutral aliases only
│   ├── functions.zsh     wt, take, up, port, extract
│   └── prompt.zsh        powerlevel10k + everforest
├── os/
│   ├── Darwin.zsh        homebrew, GNU coreutils, pbcopy
│   ├── Linux.zsh         pacman, wl-copy/xclip
│   └── wsl.zsh           layered on top of Linux.zsh when WSL is detected
└── local.zsh             gitignored
```

Load order in `config.zsh` is mostly not reorderable. Two constraints will bite
you:

- `compinit` must run before fzf-tab, which wraps the completion widget.
- `fast-syntax-highlighting` must be **last**. It wraps every ZLE widget
  defined up to that point; anything loaded after it is not highlighted.

WSL reports `uname -s` as `Linux`, so `os/Linux.zsh` loads first and
`os/wsl.zsh` layers the interop differences on top: Windows-side clipboard,
`wslview` for opening URLs, and pruning the Windows PATH entries that interop
appends (which otherwise make command completion crawl).

### Adding to zsh

| You want to add | Put it in |
| --- | --- |
| an alias that works everywhere | `lib/aliases.zsh` |
| an alias with different BSD/GNU flags | `os/Darwin.zsh` + `os/Linux.zsh` |
| a function | `lib/functions.zsh` |
| a keybinding | `lib/keybinds.zsh` |
| a `setopt` | `lib/options.zsh` |
| a PATH entry | `lib/path.zsh`, or `local.zsh` if machine-specific |
| anything work-related | `local.zsh` |

## tmux

```
tmux/
├── tmux.conf              ordered entry point
├── conf/
│   ├── options.conf       terminal caps, extended-keys, indexes, history
│   ├── keys.conf          prefix, splits, windows, sessions, popups
│   ├── navigation.conf    root-table C-hjkl, shared with neovim
│   ├── copy.conf          vi copy mode, platform clipboard
│   └── status.conf        statusline layout — reads @t_* only
├── theme/
│   ├── everforest.conf    tracked default palette
│   └── rivendell.conf     tracked alternate palette
├── theme.conf             gitignored; generated override slot
└── local.conf             gitignored
```

Themes are expressed as `@t_*` user options, which is the naming
`~/.config/rice/apply-theme.sh` already emits. So a generated `theme.conf`
drops in and overrides the tracked palette without touching `status.conf`, and
a partial override (just `@t_accent`, say) falls back to the default for
everything else. To change the tracked default, edit the one theme line in
`tmux.conf`.

Prefix is `C-Space`.

| Key | Action |
| --- | --- |
| `C-hjkl` (no prefix) | move between panes **and** nvim splits |
| `M-hjkl` (no prefix) | resize pane / nvim split |
| prefix `r` | reload config |
| prefix <code>&#124;</code> / `-` | split right / down, inheriting cwd |
| prefix `c` | new window in cwd |
| prefix `z` | zoom pane |
| prefix `f` | tmux-sessionizer |
| prefix `s` | session tree |
| prefix `g` | lazygit popup |
| prefix `t` | shell popup in cwd |
| prefix `C-n` / `C-p` | next / previous window |
| prefix `Tab` | last window |
| prefix `<` / `>` | move window left / right |
| prefix `[` | copy mode (then `v` select, `y` copy, `C-v` rectangle) |
| prefix `/` | copy mode, search backwards |

## neovim

A submodule with its own remote. Commit inside `nvim/`, then commit the pointer
bump in `~/.config`. Full keymap reference: `nvim/KEYMAPS.md`, or `<leader>?`
in nvim for the live version.

```
nvim/
├── init.lua              5 requires, nothing else
├── KEYMAPS.md
├── lazy-lock.json        tracked — this is what makes a rebuild reproducible
├── lua/config/
│   ├── platform.lua      OS detection; WSL clipboard, Windows shell
│   ├── options.lua       vim.opt, sets mapleader
│   ├── keymaps.lua       maps with no plugin dependency
│   ├── autocmds.lua
│   └── lazy.lua          plugin-manager bootstrap
├── lua/lsp/
│   ├── servers.lua       server settings — data only, no side effects
│   └── attach.lua        buffer-local keymaps on LspAttach
└── lua/plugins/
    ├── colorscheme.lua   the only place a colorscheme is set
    ├── snacks.lua        the only picker        -> <leader>f, <leader>e
    ├── completion.lua    blink.cmp (top level, not an LSP dependency)
    ├── lsp.lua           vim.lsp.config/enable; mason is installer-only
    ├── format.lua        conform — the only formatter owner -> <leader>cf
    ├── treesitter.lua    pinned to branch=master, load-bearing
    ├── git.lua           gitsigns/fugitive/lazygit -> <leader>g, <leader>h
    ├── navigation.lua    smart-splits + harpoon -> <C-hjkl>, <leader>m
    ├── editor.lua        autopair, undotree, gx, which-key
    ├── ui.lua            lualine, trouble       -> <leader>x
    └── work.lua          Shopify plugins, all cond-guarded
```

### The rules that keep it maintainable

**One namespace, one file.** Each `<leader>` prefix has exactly one owning
file, listed in `KEYMAPS.md`. Adding a git keymap means editing `git.lua`, not
hunting through eleven files.

**Keymaps go in `keys`, not `config`.** A keymap defined inside
`config = function()` cannot trigger its own plugin load, which forces the
plugin to load eagerly at startup. Declaring it in `keys = { ... }` lets
lazy.nvim create a stub and load on first press. This single rule is why the
eager-plugin count is 3 instead of 10.

**Platform checks come from `config.platform`.** Do not re-derive `uname` in a
plugin spec.

**Work plugins use `cond`.** Anything Shopify-specific is guarded so it is
inert elsewhere — nothing cloned, nothing loaded, no errors. Never hardcode an
absolute path in a spec; derive it and guard with `isdirectory`.

**`lazy-lock.json` stays tracked.** Without it a fresh clone pulls
latest-everything. `nvim-treesitter`'s default branch is now `main`, which
removed the API this config uses, so an untracked lock plus an unpinned branch
means a config that does not start.

### Adding a plugin

Add it to the file owning its concern, or create a new file in `lua/plugins/`
if it introduces a genuinely new namespace. Give it a load trigger (`keys`,
`cmd`, `ft`, or `event`) unless it truly must load at startup.

```lua
return {
  "owner/plugin.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>xy", "<cmd>Thing<cr>", desc = "Do the thing" },
  },
  opts = {},
}
```

Then `:Lazy sync` and commit the `lazy-lock.json` change.

## Native Windows

PowerShell rather than zsh — `windows/profile.ps1` mirrors the zsh
keybindings, aliases, and functions so muscle memory carries across, but wraps
native cmdlets where PowerShell has the better answer. nvim is shared
unchanged; `config.platform` handles the shell and clipboard differences.

```
windows/
├── profile.ps1     $PROFILE target: PSReadLine vi mode, aliases, prompt
├── bootstrap.ps1   winget packages, sparse profile, symlinks
└── local.ps1       gitignored
```

```powershell
pwsh -ExecutionPolicy Bypass -File $HOME\.config\windows\bootstrap.ps1
```

Symlink creation needs Developer Mode or an elevated shell. `profile.ps1` sets
`XDG_CONFIG_HOME` to `~/.config`, which nvim honours on Windows; the bootstrap
also drops a junction at `%LOCALAPPDATA%\nvim` for launches that do not inherit
the profile.

## Required tools

Core: `zsh`, `git`, `tmux`, `nvim` (0.11+), `fzf`, `ripgrep`, `fd`, `lazygit`.

`ripgrep` and `fd` are not optional — `snacks.picker` grep needs `rg`, and file
finding is much slower without `fd`.

```sh
brew install fzf ripgrep fd lazygit neovim          # macOS
sudo pacman -S fzf ripgrep fd lazygit neovim        # Arch
sudo apt install fzf ripgrep fd-find neovim         # WSL/Ubuntu
```

On WSL, install `win32yank` for clipboard sharing (nvim and `pbc`/`pbp` both
prefer it), and `wslu` for `wslview`.

## Fresh machine

```sh
git clone --recurse-submodules https://github.com/archiso7/dotfiles ~/.config
cd ~/.config
bin/dotfiles-profile --detect
ln -sf ~/.config/zsh/zshrc ~/.zshrc
cp zsh/local.zsh.example zsh/local.zsh    # then edit
```

Launch nvim once and let lazy.nvim install from `lazy-lock.json`.

## Branches

| Branch | Purpose |
| --- | --- |
| `main` | current |
| `restructure` | this work: nvim + zsh + tmux refactor, reorg merged |
| `reorg` | personal-laptop snapshot, merged into `restructure` |
| `master` | dead; strict ancestor of `main`, safe to delete |

## Known gaps

Switching to a profile that excludes `zsh/` leaves the directory on disk, with
`warning: unable to rmdir 'zsh/powerlevel10k': Directory not empty`. Git cannot
remove a directory containing populated submodule worktrees. Harmless — nothing
reads it under the `windows` profile — but it means profile switching is not a
perfectly clean sweep. `git submodule deinit` first if you actually want it gone.

`hypr/theme.conf` and `kitty/theme-override.conf` are generated by the rice
theme switcher but remain **tracked**, unlike `tmux/theme.conf`. Hyprland's
`source =` and kitty's `include` have no quiet-if-missing form, so a tracked
default is the pragmatic choice; the cost is that regenerating a theme shows up
as a dirty diff.

`~/.config/rice/` (the theme switcher) and `~/.config/wm-common/` (scripts bound
to Hyprland keys) are referenced by the Arch config but tracked in **no**
branch. They exist only on the Arch laptop. `rice/`, `wm-common/`, `fuzzel/`
and `wpg/` are already whitelisted in `.gitignore` and listed in
`profiles/arch`, so recovery on that machine is just:

```sh
cd ~/.config
git fetch origin && git checkout main && git pull
git add rice wm-common fuzzel wpg
git commit -m "recover Arch desktop scripts"
git push origin main
bin/dotfiles-profile arch
```

Do this **before** wiping the laptop.
