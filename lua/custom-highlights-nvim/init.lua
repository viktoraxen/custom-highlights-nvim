local M = {}

local colorschemes = {
    catppuccin = {
        pattern = "catppuccin",
        palette = function()
            local name = vim.g.colors_name
            local flavour = string.gsub(name, "catppuccin%-", "")
            local palette = require("catppuccin.palettes").get_palette(flavour)

            return palette
        end
    }
}

local resolve_colors = function(palette, colors)
    local resolved_colors = {}

    if colors.fg then
        resolved_colors.fg = palette[colors.fg]
    end

    if colors.bg then
        resolved_colors.bg = palette[colors.bg]
    end

    if colors.italic then
        resolved_colors.italic = colors.italic
    end

    return resolved_colors
end

local apply_customizations = function(palette, highlights)
    for _, h in ipairs(highlights) do
        local group = h[1]
        local colors = resolve_colors(palette, h[2])

        vim.api.nvim_set_hl(0, group, colors)
    end
end

local apply_links = function(links)
    for _, l in ipairs(links) do
        vim.api.nvim_set_hl(0, l.src, { link = l.dst })
    end
end

M.setup = function(opts)
    apply_links(opts.links)

    vim.api.nvim_create_augroup('ColorCallback', { clear = true })

    for name, highlights in pairs(opts.customizations) do
        vim.api.nvim_create_autocmd('ColorScheme', {
            group = 'ColorCallback',
            pattern = colorschemes[name].pattern,
            callback = function()
                apply_customizations(colorschemes[name].palette(), highlights)
            end,
        })
    end
end

return M
