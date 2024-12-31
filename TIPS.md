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

another example
```lua

local spinners = {}

--- @param _start number
--- @param _end number
--- @param message string
--- @return number id
M.spinner_start = function(_start, _end, message)
    -- frames: | / ─ \ | / ─ \ |
    local timer = vim.uv.new_timer()
    local frame = 0
    local id = #spinners + 1
    spinners[id] = true

    timer:start(
        0,
        250,
        vim.schedule_wrap(function()
            draw_spinner(id, frame) -- use extmark, ns tied to ID
            if not spinners[id] then
                timer:stop()
                timer:close()
            end
        end)
    )
    return id
end

--- @param id number spinner id
M.spinner_stop = function(id)
    spinners[id] = false
    local active = #vim.tbl_filter(function(value)
        return value
    end, spinners)
    if active == 0 then
        tbl_clear(spinners)
    end
end
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
