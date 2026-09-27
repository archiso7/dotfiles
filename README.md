# dotfiles

`~/.config` is the git repository itself. There is no symlink farm and no stow
— files live where the application expects them. The one exception is
`~/.zshrc`, which is a symlink to `zsh/zshrc` because zsh insists on reading it
from `$HOME`.

## What is tracked

`.gitignore` is an allowlist: it ignores `*` and then re-includes specific
directories. This is deliberate. `~/.config` also contains a lot of
machine-generated and work-only state (`dev/`, `gcloud/`, `psst/`,
`shopify-ai-dev/`, `graphite/`, …) that should never be committed, and an
allowlist means new tooling defaults to *not* tracked.

To start tracking a new directory, add both lines:

```gitignore
!/foo/
!/foo/**
```

## Layout

```
.config/
├── nvim/           neovim (git submodule -> github.com/archiso7/nvim)
├── zsh/            shell
├── tmux/           terminal multiplexer
├── tmux-sessionizer/
├── hypr/           Hyprland compositor      (Linux only)
├── waybar/         status bar               (Linux only)
├── wofi/           launcher                 (Linux only)
└── kitty/          terminal                 (Linux only)
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
work toolchains, private paths, and per-host quirks belong. Copy the example to
start:

```sh
cp ~/.config/zsh/local.zsh.example ~/.config/zsh/local.zsh
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
│   └── Linux.zsh         pacman, wl-copy/xclip
├── local.zsh             gitignored
└── local.zsh.example
```

Load order in `config.zsh` is mostly not reorderable. The two constraints that
will bite you:

- `compinit` must run before fzf-tab, which wraps the completion widget.
- `fast-syntax-highlighting` must be **last**. It wraps every ZLE widget
  defined up to that point; anything loaded after it is not highlighted.

### Adding to zsh

| You want to add | Put it in |
| --- | --- |
| an alias that works everywhere | `lib/aliases.zsh` |
| an alias with different BSD/GNU flags | `os/Darwin.zsh` and `os/Linux.zsh` |
| a function | `lib/functions.zsh` |
| a keybinding | `lib/keybinds.zsh` |
| a `setopt` | `lib/options.zsh` |
| a PATH entry | `lib/path.zsh` (or `local.zsh` if machine-specific) |
| anything work-related | `local.zsh` |

## neovim

This is a submodule with its own remote. Commit inside `nvim/`, then commit the
pointer bump in `~/.config`.

```
nvim/
├── init.lua              4 requires, nothing else
├── KEYMAPS.md            full keymap reference
├── lazy-lock.json        tracked — this is what makes a rebuild reproducible
├── lua/config/
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

**Work plugins use `cond`.** Anything Shopify-specific is guarded so it is
inert elsewhere — nothing cloned, nothing loaded, no errors. Never hardcode an
absolute path in a spec; derive it and guard with `isdirectory`.

**`lazy-lock.json` stays tracked.** Without it a fresh clone pulls
latest-everything. `nvim-treesitter`'s default branch is now `main`, which
removed the API this config uses, so an untracked lock plus an unpinned branch
means a config that does not start.

### Adding a plugin

Add it to the file owning its concern, or create a new file in `lua/plugins/`
if it introduces a genuinely new namespace. Give it a load trigger
(`keys`, `cmd`, `ft`, or `event`) unless it truly must load at startup.

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

Then run `:Lazy sync` and commit the `lazy-lock.json` change.

## Required tools

Core: `zsh`, `git`, `tmux`, `nvim` (0.11+), `fzf`, `ripgrep`, `fd`, `lazygit`.

`ripgrep` and `fd` are not optional — `snacks.picker` grep needs `rg`, and file
finding is much slower without `fd`. Neither was installed before the
restructure, which is why a second picker with its own bundled binary had
looked necessary.

```sh
# macOS
brew install fzf ripgrep fd lazygit neovim

# Arch
sudo pacman -S fzf ripgrep fd lazygit neovim
```

## Fresh machine

```sh
git clone --recurse-submodules https://github.com/archiso7/dotfiles ~/.config
ln -sf ~/.config/zsh/zshrc ~/.zshrc
cp ~/.config/zsh/local.zsh.example ~/.config/zsh/local.zsh   # then edit
```

Launch nvim once and let lazy.nvim install from `lazy-lock.json`.

## Branches

| Branch | Purpose |
| --- | --- |
| `main` | current |
| `reorg` | personal-laptop snapshot: theme extraction, per-compositor waybar |
| `restructure` | this work |
| `master` | dead; strict ancestor of `main`, safe to delete |
