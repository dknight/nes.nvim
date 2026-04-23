# nes.nvim

Simple Neovim plugin for building and running NES (6502, ca65) projects.

## Installation (lazy.nvim)

Basic config, here `fceux` is set as emulator, you can choose your own.

```lua
{
  "dknight/nes.nvim",
  name = "nes.nvim",
  opts = {
    emulator = "fceux", -- or your own emulator
  }
}
```

## Commands

`:NesBuild` - compile + link;
`:NesRun` - compile + link + run;
`:NesClean` - remove `*.o` and `*.nes` files.

## Keymaps (asm\_ca65)

`<leader>b` - build
`<leader>r` - run
`<leader>x` - clean

## Configuration (Optional)

Configuration can be override on plugin initialization.

```lua
{
  "dknight/nes.nvim",
  name = "nes.nvim",
  ft = { "asm_ca65" },
  cmd = { "NesBuild", "NesRun", "NesClean" },

  opts = {
    compiler = "ca65",
    linker = "cl65",
    emulator = "fceux",
    target = "nes",
    build_key = "<leader>b",
    run_key = "<leader>r",
    clean_key = "<leader>x",
  },

  config = function(_, opts)
    require("nes").setup(opts)
  end,
}
```
