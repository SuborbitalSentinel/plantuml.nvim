-- https://www.youtube.com/watch?app=desktop&v=n4Lp4cV8YR0 : 36:25
vim.api.nvim_create_user_command("ReloadPlantUML", function()
    package.loaded["plantuml.nvim"] = nil
end, {})

vim.api.nvim_create_user_command("PreviewUML", function()
    local bufnr = vim.api.nvim_get_current_buf()
    require("plantuml.nvim").preview_buffer(bufnr)
end, {})

vim.api.nvim_create_user_command("StopPreviewUML", function()
    local bufnr = vim.api.nvim_get_current_buf()
    require("plantuml.nvim").stop_preview_buffer(bufnr)
end, {})
