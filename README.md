![nes.nvim](docs/images/nesnvim.png)

Simple Neovim plugin for building and running NES or Famicom (6502) projects.
Also it allows to simulate standalone 6502 program in simulator (sim65).

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

- `:NesBuild` - builds the project, compile -> link;
- `:NesRun` - builds and runs the project in emulateor: compile -> link -> run;
- `:NesClean` - remove `*.o` and `*.nes` files;
- `:NesCreateMakefile` - generates Makefile from [template](https://github.com/dknight/nes.nvim/tree/main/templates/Makefile.template).
- `:Nes6502Simulate` - simulates the program in 6502 simulator (sim65 is default).

## Keymaps (asm\_ca65)

- `<leader>b` - :NesBuild
- `<leader>r` - :NesRun
- `<leader>x` - :NesClean
- `<leader>m` - :NesCreateMakefile
- `<leader>i` - :Nes6502Simulate

Or you can defined own keys in plugin's config, like:

```lua
{
  "dknight/nes.nvim",
  name = "nes.nvim",

  opts = {
    -- ...
        run_key = "<F5>",
        build_key = "<F6>",
        simulate_key = "<F9>",
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

  cmd = {
    "NesBuild", 
    "NesRun",
    "NesClean",
    "NesCreateMakefile",
    "Nes6502Simulate",
  },

  opts = {
    save_before_compile = true,
    compiler = "ca65",
    linker = "cl65",
    emulator = "fceux",
    target = "nes",
    use_make = false,
    build_key = "<leader>b",
    run_key = "<leader>r",
    clean_key = "<leader>x",
    create_makefile_key = "<leader>m",
    simulate_key = "<leader>i",
  },
}
```
