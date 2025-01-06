# Neovim

<img width="1512" alt="image" src="https://github.com/user-attachments/assets/db047b1b-4b69-4f46-951d-26992242dc43">
<img width="1512" alt="image" src="https://github.com/user-attachments/assets/2ce83e98-5da7-4402-a74d-a6e774bba3f4">
<img width="1512" alt="image" src="https://github.com/user-attachments/assets/f4f1b2e7-8d34-492c-bba1-97eba551f07a">
<img width="1512" alt="image" src="https://github.com/user-attachments/assets/6f29a2ff-3909-42d4-98a3-82e31f88e092">


### Prerequisites

- install nvim, for macOS you can run `brew install neovim`
   
### Theming

This setup uses [`night-owl`](https://github.com/oxfist/night-owl.nvim) with the experimental noice UI.
- I use [this background](https://www.reddit.com/r/wallpapers/comments/xbnouy/the_not_so_void_black_hole_by_victor_sales/) and iterm2 with opacity 5%

### Debugging

#### JS/TS

To use `pwa-chrome` and attach to a project, startup chrome 
in debug mode, such as 
```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222
```
Then you can attach to the running chrome session and put breakpoints in your code. 

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

### What's Next

- steps extension
 - have a floating buffer where you can modify a "stack" of next steps
 - next step displayed in winbar
 - cycle steps via ] / [ 
 - complete a step as well
 - add / modify in the float (such as changing order)
 - since it's a stack, last added item on top
 - we'll overlay the text content
 - insert mode will wipe the ns 
 - back to normal, grab buffer content and update stack + draw again
 - dd will delete a step and we'll re-draw
- player
 - winbar of current music playing (uses CLI)
 - callback after song ends / prev / next / play

### Plugins
```
    ● cmp-buffer 0.2ms  nvim-cmp
    ● cmp-nvim-lsp 0.2ms  nvim-cmp
    ● cmp-path 0.2ms  nvim-cmp
    ● cmp_luasnip 0.11ms  nvim-cmp
    ● copilot.vim 1.44ms  CopilotChat.nvim
    ● CopilotChat.nvim 7.36ms  start
    ● curl.nvim 0.93ms  start
    ● diffview.nvim 3.69ms  VeryLazy
    ● fidget.nvim 0.63ms  nvim-lspconfig
    ● FixCursorHold.nvim 0.31ms  neotest
    ● flash.nvim 0.96ms  VeryLazy
    ● friendly-snippets 0.22ms  nvim-cmp
    ● harpoon 1.34ms  VeryLazy
    ● lazy.nvim 10.39ms  init.lua
    ● lazydev.nvim 0.51ms  nvim-lspconfig
    ● lspkind.nvim 0.18ms  nvim-cmp
    ● lua-async-await 0.15ms  nvim-java
    ● LuaSnip 3.43ms  nvim-cmp
    ● mason-lspconfig.nvim 0.17ms  nvim-lspconfig
    ● mason.nvim 2.58ms  nvim-java
    ● mini.nvim 2.9ms  VeryLazy
    ● neotest 7.96ms  VeryLazy
    ● neotest-go 0.22ms  neotest
    ● neotest-jest 0.3ms  neotest
    ● neotest-python 0.22ms  neotest
    ● night-owl.nvim 2.81ms  start
    ● noice.nvim 0.8ms  VeryLazy
    ● nui.nvim 0.19ms  nvim-java
    ● nvim-cmp 5.61ms  nvim-lspconfig
    ● nvim-dap 0.34ms  nvim-java
    ● nvim-dap-go 0.25ms  nvim-dap-ui
    ● nvim-dap-python 0.26ms  nvim-dap-ui
    ● nvim-dap-ui 3.52ms  VeryLazy
    ● nvim-dap-virtual-text 0.27ms  nvim-dap-ui
    ● nvim-java 23.9ms  nvim-lspconfig
    ● nvim-java-core 0.17ms  nvim-java
    ● nvim-java-dap 0.15ms  nvim-java
    ● nvim-java-refactor 0.17ms  nvim-java
    ● nvim-java-test 0.34ms  nvim-java
    ● nvim-lint 0.04ms  VeryLazy
    ● nvim-lspconfig 49.77ms  start
    ● nvim-neoclip.lua 0.2ms  telescope.nvim
    ● nvim-nio 0.23ms  neotest
    ● nvim-treesitter 5.75ms  refactoring.nvim
    ● nvim-web-devicons 0.15ms  octo.nvim
    ● octo.nvim 14.02ms  VeryLazy
    ● plenary.nvim 0.42ms  refactoring.nvim
    ● refactoring.nvim 12.14ms  start
    ● rose-pine 0.19ms  start
    ● rustaceanvim 0.04ms  start
    ● spring-boot.nvim 0.18ms  nvim-java
    ● telescope-fzf-native.nvim 0.2ms  telescope.nvim
    ● telescope.nvim 10.4ms  octo.nvim
    ● todo-comments.nvim 0.9ms  VeryLazy
    ● toggleterm.nvim 1.61ms  BufEnter
    ● tokyonight.nvim 0.1ms  start
    ● trouble.nvim 1.24ms  VeryLazy
    ● undotree 0.24ms  VeryLazy
    ● vim-table-mode 0.48ms  BufEnter
    ● conform.nvim  ConformInfo  <leader>rf  <leader>rf (v)  BufWritePre 
```

<img width="1512" alt="image" src="https://github.com/user-attachments/assets/3df88f9f-d4d3-4e09-91dc-17e851c25201">
