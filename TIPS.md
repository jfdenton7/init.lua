### Fancy Edits

1. Create 10 lines with 0. at the beginning `10o0.<esc>`
2. Select paragraph `vip`
3. Use `g<C-a>`

### One offs

- use `tcd` to change current tab's dir.

### Diffview oditities

Best to close the tab via `:tabc`

### G command

read commands via `:help g`

### DAP

- debug log found at `~/.cache/nvim/dap.log`


### Start a Timer

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

### DB

Example connecting to sqlite
```
sqlite:///path/to/your/database/file.db
```

Example connecting to mysql
```
mysql://user:password@host:port/database
```

HMM - vim.fn.matchadd(
