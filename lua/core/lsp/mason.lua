local M = {}

local ui = require("core.ui.style")
local custom_handlers = require("core.lsp.handlers")

local handlers = function(server_name)
    local default = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = ui.rounded_border() }),
        ["textDocument/signatureHelp"] = vim.lsp.with(
            vim.lsp.handlers.signature_help,
            { border = ui.rounded_border() }
        ),
        ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            border = ui.rounded_border(),
            -- Disable virtual_text
            underline = true,
            virtual_text = false,
        }),
    }

    return vim.tbl_extend("force", default, custom_handlers[server_name] or {})
end

M.setup = function()
    require("mason").setup()

    local mason_lspconfig = require("mason-lspconfig")

    -- get settings
    local settings = require("core.lsp.settings")
    local servers = require("core.lsp.servers")

    mason_lspconfig.setup({
        ensure_installed = vim.tbl_keys(servers),
    })

    mason_lspconfig.setup_handlers({
        function(server_name)
            require("lspconfig")[server_name].setup({
                handlers = handlers(server_name),
                capabilities = settings.capabilities,
                on_attach = settings.on_attach,
                settings = servers[server_name],
                filetypes = (servers[server_name] or {}).filetypes,
            })
        end,
        ["rust_analyzer"] = function() end, -- rustaceanvim takes care of this
    })
end

return M
