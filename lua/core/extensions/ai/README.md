# Plan

- [ ] action menu with options 
  - Generate (test, usage, data)
  - Task (set task context that can be used by copilot)
  - Plan (next step, ...)
  - Diagnose (error, race condition, ...)
  - Learn
  - Quiz
- [ ] for learn & quiz & generate, need a way to store them (probably just json + custom files)
- [ ] automate runtime complexity analysis with extmark / in-line comments
- [ ] custom contexts that you can turn off / on, modify the highlights based on options
- [ ] auto create "next step" content and inject into completion engine

```lua
local source = {}

source.new = function()
  local self = setmetatable({}, { __index = source })
  return self
end

source.is_available = function()
  return true
end

source.complete = function(self, request, callback)
  local items = {
    { label = 'CustomItem1', insertText = 'CustomText1', kind = vim.lsp.protocol.CompletionItemKind.Text },
    { label = 'CustomItem2', insertText = 'CustomText2', kind = vim.lsp.protocol.CompletionItemKind.Text },
    { label = 'CustomItem3', insertText = 'CustomText3', kind = vim.lsp.protocol.CompletionItemKind.Text },
  }
  callback({ items = items, isIncomplete = false })
end

source.resolve = function(self, completion_item, callback)
  callback(completion_item)
end

source.execute = function(self, completion_item, callback)
  callback(completion_item)
end

return source

--- where you setup cmp...
-- Register the custom source
cmp.register_source('my_custom_source', my_custom_source.new())
```

```lua
    local prompt = [[
<rules>
find any code where the following applies 
- errors or race conditions
- duplicate code
- deeply nested code blocks (>=3 depth)
- magic values used >1 time
- incorrect logic

return each finding on a newline, in the following format
```
<number>: <message>
```
</rules>

<code>
#buffer
</code>
        ]]
    chat.ask(prompt, {
        headless = true,
        callback = function(response, _)
            vim.print(response)
            local lines = vim.split(response, "\n")
            lines = vim.list_slice(lines, 2, #lines - 1)
            vim.print(lines)
            -- local content = vim.fn.join(lines, "\n")
            -- local issues = vim.fn.json_decode(content)
            -- if type(issues) ~= "table" then
            --     local id = mini_notify.add("Failed to parse 'fix' output", "ERROR", "DiagnosticError")
            --     vim.defer_fn(function()
            --         mini_notify.remove(id)
            --     end, 1500)
            --     return
            -- end
            --- @type table<vim.Diagnostic>
            local diagnostics = {}
            for _, line in ipairs(lines) do
                vim.split(line, ":")
                tonumber()
                table.insert(diagnostics, {
                    lnum = issue.lnum - 1, -- Convert to 0-indexed
                    col = 0, -- Assuming column is 0 if not provided
                    severity = vim.diagnostic.severity.HINT,
                    message = issue.message,
                    source = "_copilot",
                })
            end

            local review_ns = vim.api.nvim_create_namespace("user_copilot_review_diagnostics")
            vim.diagnostic.set(review_ns, 0, diagnostics, { virtual_text = true })

            local id = mini_notify.add("Added diagnostics to buffer", "INFO", "DiagnosticOk")
            vim.defer_fn(function()
                mini_notify.remove(id)
            end, 1500)
        end,
    })
```
