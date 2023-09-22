local M = {}
local keymap = vim.keymap.set

-- local def_capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = require('cmp_nvim_lsp').default_capabilities()

local function lsp_keymaps(bufnr)
    local buf_opts = { buffer = bufnr, silent = true }
    local telescope_builtins = require('telescope.builtin')

    keymap('n', 'gl', vim.diagnostic.open_float, buf_opts)
    keymap('n', 'gd', vim.lsp.buf.definition, buf_opts)
    keymap('n', 'K', vim.lsp.buf.hover, buf_opts)

    keymap('n', 'gr', telescope_builtins.lsp_references, buf_opts)
    keymap('n', 'gI', telescope_builtins.lsp_implementations, buf_opts)

    keymap('n', '<leader>rn', vim.lsp.buf.rename, buf_opts)
    keymap('n', '<leader>ca', vim.lsp.buf.code_action, buf_opts)
    keymap('n', '<leader>ds', telescope_builtins.lsp_document_symbols, buf_opts)
    keymap('n', '<leader>ws', telescope_builtins.lsp_dynamic_workspace_symbols, buf_opts)

    keymap('n', '<leader>p', vim.lsp.buf.format, buf_opts)
end

M.on_attach = function(_, bufnr)
    lsp_keymaps(bufnr)
end


return M

