# Neovim

<img width="1512" alt="image" src="https://github.com/josiahdenton/init.lua/assets/44758384/7ae5e4b1-6c49-4b88-8954-3f9dd4706907">
<img width="1512" alt="image" src="https://github.com/josiahdenton/init.lua/assets/44758384/2d3e1488-274b-4ccb-bf7c-9a936dfbdeeb">
<img width="1512" alt="image" src="https://github.com/josiahdenton/init.lua/assets/44758384/e45e1153-57df-4b96-b930-3452d3569a21">


### Prerequisites

- install nvim, for macOS you can run `brew install neovim`
    - run `brew install luajit` as well for neorg dependency
    - run `brew install gnu-sed` for spectre dependency
    - run `brew install gcc-12` for neorg

### Theming

This setup uses `terafox` with the experimental noice UI.
- I use [this background](https://codeberg.org/nine_point_eight/config-files/src/branch/master/config-files/wallpapers/everforest-conifer.jpg) and iterm2 with opacity 5%

### Debugging

#### Python

To debug python, dap-python comes with many defaults. To run
any module that imports relative, you must create an .nvim.lua file, e.g.
```lua
table.insert(require("dap").configurations.python, {
    type = "python",
    request = "launch",
    name = "Run Module",
    console = "integratedTerminal",
    module = "src.adapter.client", -- edit this to the module you are debugging
    cwd = "${workspaceFolder}",
    justMyCode = false,
})
```

### Setup

This setup requires `0.10.x` or above. During your first open,
Lazy (the package manager) will install itself if not found.
If you want to use dap, you will need the debugger tools, such as
- [debugpy for python](https://github.com/microsoft/debugpy)
- [codelldb for rust](https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb))

### Tips and Tricks

```lua
-- a nice way to write a timer
local timer = vim.uv.new_timer()
timer:start(500, 0, function()
    timer:stop()
    vim.schedule_wrap(function ()
        vim.cmd("nohlsearch")
    end)
end)
```
