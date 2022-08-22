local augroup = vim.api.nvim_create_augroup('prettierrc', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', {
    group = augroup,
    callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            require('prettierrc').init(buf)
        end
    end,
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead', 'BufFilePost' }, {
    group = augroup,
    callback = function(data)
        require('prettierrc').init(data.buf)
    end,
})
