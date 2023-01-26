local M = {}

M.settings = {
    sever_url = 'http://localhost:8080/form'
}

M.setup = function(opts)
    if opts.server_url ~= nil then
        M.settings.server_url = opts.server_url
    end
end

M.call_server = function()
end

M.update_buffer = function()
end

M.preview_buffer = function(bufnr)
end

M.stop_preview_buffer = function(bufnr)
end

return M
