# nes.nvim

![https://raw.githubusercontent.com/dknight/nes.nvim/refs/heads/main/nesnvim.png](NES.NVIM)

Simple Neovim plugin for building and running NES or Famicom (6502)
projects.

## Installation (lazy.nvim)

Basic config, here `fceux` is set as emulator, you can choose your own.

```lua
{
  "dknight/nes.nvim",
  name = "nes.nvim",
  opts = {
    emulator = "fceux", -- or your own emulator
  },
  -- If you wish to use snippets.
  dependencies = {
    "L3MON4D3/LuaSnip",
  },
}
```

## Commands

- `:NesBuild` - compile + link;
- `:NesRun` - compile + link + run;
- `:NesClean` - remove `*.o` and `*.nes` files.

## Keymaps (asm\_ca65)

- `<leader>b` - build
- `<leader>r` - run
- `<leader>x` - clean

Or you can defined own keys in plugin's config, like:

```lua
{
  "dknight/nes.nvim",
  name = "nes.nvim",

  opts = {
    -- ...
    build_key = "<F6>",
    run_key = "<F7>",
    clean_key = "<F10>",
  },
```

## Configuration (Optional)

Configuration can be override on plugin initialization.

```lua
{
  "dknight/nes.nvim",
  name = "nes.nvim",
  ft = { "asm_ca65" },
  dependencies = {
    "L3MON4D3/LuaSnip",
  },

  cmd = { "NesBuild", "NesRun", "NesClean" },

  opts = {
    save_before_compile = true,
    compiler = "ca65",
    linker = "cl65",
    emulator = "fceux",
    target = "nes",
    build_key = "<leader>b",
    run_key = "<leader>r",
    clean_key = "<leader>x",
  },
}
```
