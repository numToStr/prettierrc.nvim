---@mod prettierrc Prettierrc.nvim

-- TODO
-- [ ] hidden and excluded files/folders
-- [ ] only apply settings to child and sibling files of config
-- [ ] async file read

local uv, bo = vim.loop, vim.bo

---@class Prettierrc Supported `.prettierrc` options
---@field tabWidth integer
---@field printWidth integer
---@field useTabs integer
---@field endOfLine 'lf'|'cflf'|'cr'|'auto'

local P, setting, cache = {}, {}, { mtime = -1 }
local is_win = string.find(uv.os_uname().sysname, '^Win') ~= nil
local cr = is_win and '\r\n' or '\n'
local yml_pat = '^%s*(%w+)%s*:?=?%s*"?(.-)"?%s*$'
local fileformat = { lf = 'unix', crlf = 'dos', cr = 'mac' }
local files = {
    '.prettierrc',
    '.prettierrc.json',
    '.prettierrc.yml',
    '.prettierrc.yaml',
    '.prettierrc.toml',
}

---For `tabWidth` and updates |tabstop|, |shiftwidth|, |softtabstop|
---@param buf integer Buffer ID
---@param size integer
---@param opts Prettierrc
function setting.tabWidth(buf, size, opts)
    bo[buf].tabstop = size
    if opts.useTabs then
        bo[buf].shiftwidth = 0
        bo[buf].softtabstop = 0
    else
        bo[buf].shiftwidth = size
        bo[buf].softtabstop = -1
    end
end

---For `useTabs` and updates |expandtab|, |shiftwidth|, |softtabstop|
---@param buf integer Buffer ID
---@param yes boolean
---@param opts Prettierrc
function setting.useTabs(buf, yes, opts)
    bo[buf].expandtab = not yes
    if yes and not opts.tabWidth then
        bo[buf].shiftwidth = 0
        bo[buf].softtabstop = 0
    end
end

---For `printWidth` and updates |textwidth|
---@param buf integer Buffer ID
---@param size integer
function setting.printWidth(buf, size)
    bo[buf].textwidth = size
end

---For `endOfLine` and updates |fileformat|
---@param buf integer Buffer ID
---@param val string
function setting.endOfLine(buf, val)
    if val ~= 'auto' then
        bo[buf].fileformat = fileformat[val]
    end
end

---Parse yaml/toml file into lua object
---@param file any Yaml file
---@return Prettierrc
local function yaml(file)
    local config = {}
    for line in vim.gsplit(file, cr, true) do
        if not (line == '' or string.find(line, '^%s*#')) then
            local k, v = string.match(line, yml_pat)
            if v == 'false' then
                config[k] = false
            elseif v == 'true' then
                config[k] = true
            else
                config[k] = tonumber(v) or v
            end
        end
    end
    return config
end

---Find prettier config file
---@return string? path Path to prettier config
function P.find_config()
    return vim.fs.find(files, {
        type = 'file',
        ignore = function(path)
            return (path:find('node_.-$') or path:find('%.git.-$') or path:find('%.next$'))
                or not path:find('.*%..-rc.*$')
        end,
    })[1]
end

---Parse prettier configuration into lua object from the given {path}
---@param path string Path to prettier config
---@return Prettierrc
function P.parse(path)
    local stat = assert(uv.fs_stat(path))
    if stat.mtime.nsec == cache.mtime then
        return cache.config
    end
    local fd = assert(uv.fs_open(path, 'r', 438))
    local file = assert(uv.fs_read(fd, stat.size, 0))
    assert(uv.fs_close(fd))
    local ok, json = pcall(vim.json.decode, file)
    local parsed = ok and json or yaml(file)
    cache.mtime = stat.mtime.nsec
    cache.config = parsed
    return parsed
end

---Get the config from `.prettierrc`
---@return Prettierrc?
function P.get_config()
    local path = P.find_config()
    if not path then
        return
    end
    return P.parse(path)
end

---Apply the settings to a given buffer
---@param buf integer Buffer ID
---@param config Prettierrc?
function P.apply(buf, config)
    if config ~= nil then
        for k, v in pairs(config) do
            pcall(setting[k], buf, v, config)
        end
    end
end

return P
