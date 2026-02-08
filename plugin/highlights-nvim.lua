vim.api.nvim_create_augroup("CustomHighlights", { clear = true })

local timer = vim.uv.new_timer()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = "CustomHighlights",
  pattern = "*",
  desc = "Apply links and customizations.",
  callback = function()
    timer:stop()
    timer:start(
      5,
      0,
      vim.schedule_wrap(function()
        require("highlights-nvim").apply_highlights()

        if vim.api.nvim_get_hl(0, { name = "Normal" }).bg then
          io.write(string.format("\027]11;#%06x\027\\", vim.api.nvim_get_hl(0, { name = "Normal" }).bg))
        end
      end)
    )
  end,
})
