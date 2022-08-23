local rc = require('prettierrc')

local augroup = vim.api.nvim_create_augroup('prettierrc', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', {
    group = augroup,
    callback = function()
        vim.schedule(function()
            local config = rc.get_config()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                rc.apply(buf, config)
            end
        end)
    end,
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead', 'BufFilePost' }, {
    group = augroup,
    callback = function(data)
        vim.schedule(function()
            rc.apply(data.buf, rc.get_config())
        end)
    end,
})
