local M = {}

M.setup = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")
    require("luasnip.loaders.from_vscode").lazy_load()
    luasnip.config.setup()

    cmp.setup({
        window = {
            completion = vim.tbl_extend("keep", {
                winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None,CursorLine:PmenuSel",
                col_offset = -3,
                side_padding = 0,
            }, cmp.config.window.bordered()),
            documentation = cmp.config.window.bordered(),
        },
        completion = {
            completeopt = "menu,menuone",
        },
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-d>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-q>"] = cmp.mapping.close(),
            ["<C-Space>"] = cmp.mapping.complete({}),
            -- ['<CR>'] = cmp.mapping.confirm { -- will rely on C-y for this...
            --     behavior = cmp.ConfirmBehavior.Replace,
            --     select = true,
            -- },
            ["<Tab>"] = cmp.mapping(function(fallback)
                -- local copilot = require('copilot.suggestion')

                -- only supported in copilot.lua
                -- if copilot.is_visible() then
                --     copilot.accept()
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.locally_jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
            { name = "lazydev", group_index = 0 }, -- set group index to 0 to skip loading LuaLS completions
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
        }),
        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, vim_item)
                local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
                local strings = vim.split(kind.kind, "%s", { trimempty = true })
                kind.kind = " " .. (strings[1] or "") .. " "
                kind.menu = "    (" .. (strings[2] or "") .. ")"

                return kind
            end,
        },
    })
end

return M
