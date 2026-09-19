# Neovim config

A Neovim config based on [LazyVim](https://github.com/LazyVim/LazyVim), with LazyVim's plugin specs and
helpers copied into plain files so everything is visible and easy to cut. There is no LazyVim plugin
loaded behind the scenes: what you see in `lua/plugins/` is what runs.

## Attribution

This config is derived from **[LazyVim](https://github.com/LazyVim/LazyVim)** by Folke Lemaitre and
contributors, version 16.0.1 (commit `9997009`), which is licensed under the
[Apache License 2.0](LICENSE). The plugin specs, options, keymaps, autocmds and helper modules here
started as copies of LazyVim's, and the credit for that work belongs to them.

It also depends on many plugins by their own authors, including
[snacks.nvim](https://github.com/folke/snacks.nvim),
[lazy.nvim](https://github.com/folke/lazy.nvim) and
[tokyonight.nvim](https://github.com/folke/tokyonight.nvim). See `lazy-lock.json` or `:Lazy` for the full list.

### Changes from LazyVim

- No `LazyVim/LazyVim` dependency, no extras manager, news screen or deprecation shims.
- The `LazyVim.*` helper library is a local global called `Util` (`lua/util/`), trimmed to what the specs use.
- LazyVim's default extras are merged into the plain specs: blink.cmp, and the snacks picker and explorer.
- One file per plugin in `lua/plugins/` (LazyVim groups several plugins per file).
- The dashboard is removed. Running `nvim` with no arguments opens the file picker instead.
- Only the language servers listed in `lua/plugins/lsp.lua` are enabled (LazyVim also enables any server
  installed through `:Mason`).
- `<Tab>` accepts a completion (blink.cmp `super-tab` preset) instead of `<Enter>`.
- noice's LSP progress popups are off, and the dap lualine component and noice picker key were dropped.
- My own keymaps are at the end of `lua/config/keymaps.lua`.

## Layout

```
init.lua
lua/config/    options, autocmds, keymaps, lazy (plugin manager bootstrap)
lua/util/      helpers used by the plugin specs (global `Util`)
lua/plugins/   one file per plugin, delete a file to cut the plugin
```

- **Add or remove a plugin:** add or delete a file in `lua/plugins/`. Nothing else needs registering.
- **Add or remove a language server:** edit the `servers` table in `lua/plugins/lsp.lua`.
  Mason installs listed servers and they are enabled.

## Requirements

- Neovim 0.12 or newer
- `git`, a C compiler and the `tree-sitter` CLI (to build treesitter parsers)
- `ripgrep` (for grep in the picker)
- A [Nerd Font](https://www.nerdfonts.com/) in your terminal

## Install

```sh
git clone git@github.com:Ming-Bao/Nvim-config.git ~/.config/nvim
nvim
```

Plugins install themselves on first start.

## License

Apache License 2.0, see [LICENSE](LICENSE). This applies to the parts derived from LazyVim, and the same
license is used for the rest of the repository.
