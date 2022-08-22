local rc = require('prettierrc')

local augroup = vim.api.nvim_create_augroup('prettierrc', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', {
    group = augroup,
    callback = function()
        vim.schedule(function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                rc.init(buf)
            end
        end)
    end,
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead', 'BufFilePost' }, {
    group = augroup,
    callback = function(data)
        vim.schedule(function()
            rc.init(data.buf)
        end)
    end,
})
