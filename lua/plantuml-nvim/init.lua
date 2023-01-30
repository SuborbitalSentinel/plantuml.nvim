local M = {}

local curl = require("plenary.curl")
local J = require("plenary.job")
local P = require("plenary.path")

local fmt = {
    svg = 0,
    ascii = 1
}

local format_url = {
    [fmt.svg] = function(url)
        return url:gsub("/uml/", "/svg/")
    end,
    [fmt.ascii] = function(url)
        return url:gsub("/uml/", "/txt/")
    end
}

local settings = {
    server_url = 'http://localhost:8080/form'
}

local gen_dump_path = function()
    local path
    local id = string.gsub("xxxx4xxx", "[xy]", function(l)
        local v = (l == "x") and math.random(0, 0xf) or math.random(0, 0xb)
        return string.format("%x", v)
    end)
    if P.path.sep == "\\" then
        path = string.format("%s\\AppData\\Local\\Temp\\plenary_curl_%s.headers", os.getenv "USERPROFILE", id)
    else
        path = "/tmp/plenary_curl_" .. id .. ".headers"
    end
    return path
end

local get_diagram_url = function(file_path, format)
    local response = {}

    local dump_path = gen_dump_path()
    local job = J:new {
        command = "curl",
        args = {
            "-D",
            dump_path,
            "--data-urlencode",
            "text@" .. file_path,
            settings.server_url,
        },
        on_exit = function(j, code)
            if code ~= 0 then
                print(vim.inspect(j:stderr_result()))
            else
                local headers = P.readlines(dump_path)
                local status = tonumber(string.match(headers[1], "([%w+]%d+)"))

                vim.loop.fs_unlink(dump_path)
                table.remove(headers, 1)

                response = {
                    status = status,
                    headers = headers,
                    exit = code,
                }
            end
        end
    }

    job:sync(2000)

    local uml_url = vim.split(response.headers[1], " ")[2]
    return format_url[format](uml_url)
end

M.setup = function(opts)
    settings.server_url = opts.server_url or settings.server_url
end

M.preview_buffer = function(bufnr)
    local url = get_diagram_url(vim.api.nvim_buf_get_name(bufnr), fmt.ascii)
    local res = curl.get(url, {
        compressed = false
    })
    if res then
        vim.api.nvim_command('botright vsplit')
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(res.body, "\n"))
        vim.api.nvim_buf_set_option(buf, "readonly", true)
        vim.api.nvim_buf_set_keymap(buf, 'n', 'i', '<NOP>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<CMD>bwipeout<CR>', { noremap = true, silent = true })

        vim.api.nvim_win_set_buf(win, buf)
    end
end

return M
