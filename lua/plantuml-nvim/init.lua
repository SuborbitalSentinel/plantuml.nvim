local M = {}

local settings = {
    server_url = 'http://localhost:8080/form'
}

local J = require("plenary.job")
local P = require "plenary.path"

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

M.setup = function(opts)
    settings.server_url = opts.server_url or settings.server_url
end

M.call_server = function()
    local response = {}

    local file_path = "test.md"
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
            end

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
    }

    job:sync(2000)
    print(vim.inspect(response.headers[1]))
end

M.update_buffer = function()
end

M.preview_buffer = function(bufnr)
end

M.stop_preview_buffer = function(bufnr)
end

return M
