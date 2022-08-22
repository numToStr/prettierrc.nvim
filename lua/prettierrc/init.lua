-- TODO
-- [x] support comment in yaml/toml
-- [ ] only apply settings to child and sibling files of config
-- [x] windows support (probably done)
-- [x] basic caching
-- [ ] async file read

local uv = vim.loop
local bo = vim.bo

---@class Prettierrc
---@field tabWidth integer
---@field printWidth integer
---@field useTabs integer
---@field endOfLine 'lf'|'cflf'|'cr'|'auto'

local P = {}
local setting = {}
local cache = { mtime = -1 }

local is_win = uv.os_uname().sysname == 'Windows'
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

---For `tabWidth`
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

---For `useTabs`
---@param yes boolean
---@param opts Prettierrc
function setting.useTabs(buf, yes, opts)
    bo[buf].expandtab = not yes
    if yes and not opts.tabWidth then
        bo[buf].shiftwidth = 0
        bo[buf].softtabstop = 0
    end
end

---For `printWidth`
---@param size integer
function setting.printWidth(buf, size)
    bo[buf].textwidth = size
end

---For `endOfLine`
---@param val string
function setting.endOfLine(buf, val)
    if val ~= 'auto' then
        bo[buf].fileformat = fileformat[val]
    end
end

---Read file from filesystem
---@param path string
---@return string? _ If `nil`, that means file is cached
local function read_file(path)
    local fd = assert(uv.fs_open(path, 'r', 438))
    local stat = assert(uv.fs_fstat(fd))
    local data = nil
    if not (path == cache.path and stat.mtime.nsec == cache.mtime) then
        data = assert(uv.fs_read(fd, stat.size, 0))
        cache.mtime = stat.mtime.nsec
        cache.path = path
    end
    assert(uv.fs_close(fd))
    return data
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
    return vim.fs.find(files, { type = 'file' })[1]
end

---Parse prettier configuration into lua object
---@param path string Path to prettier config
---@return Prettierrc
function P.parse(path)
    local file = read_file(vim.fs.normalize(path))
    if not file then
        return cache.config
    end
    local ok, json = pcall(vim.json.decode, file)
    local parsed = ok and json or yaml(file)
    cache.config = parsed
    return parsed
end

---Configure the plugin
---@param buf integer
function P.init(buf)
    local path = P.find_config()
    if not path then
        return
    end
    local config = P.parse(path)
    for k, v in pairs(config) do
        pcall(setting[k], buf, v, config)
    end
end

return P
