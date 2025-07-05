local M = {}

local colorschemes = {
    catppuccin = {
        pattern = "catppuccin*",
        palette = function()
            return require("catppuccin.palettes").get_palette()
        end
    },
    tokyonight = {
        pattern = "tokyonight*",
        palette = function()
            return require("tokyonight.colors").setup()
        end
    }
}

local resolve_colors = function(palette, name, colors)
    local palette_or_color_code = function(id)
        if not id then return nil end

        if string.match(id, "^#\\w{6}$") then
            return id
        elseif not palette[id] then
            vim.notify(string.format("custom-highlights-nvim: No color %q available in colorscheme %q", id, name),
                "warn")
        end

        return palette[id]
    end

    return {
        fg = palette_or_color_code(colors.fg),
        bg = palette_or_color_code(colors.bg),
        italic = colors.italic
    }
end

local apply_customizations = function(name, highlights)
    local palette = colorschemes[name].palette()

    for _, h in ipairs(highlights) do
        local group = h[1]
        local colors = resolve_colors(palette, name, h[2])

        vim.api.nvim_set_hl(0, group, colors)
    end
end

local apply_links = function(links)
    for _, l in ipairs(links) do
        vim.api.nvim_set_hl(0, l.src, { link = l.dst })
    end
end

M.setup = function(opts)
    vim.api.nvim_create_augroup('CustomHighlights', { clear = true })

    local apply = function()
        apply_links(opts.links)

        local current_colorscheme = vim.g.colors_name

        if not current_colorscheme then return end

        for name, c in pairs(colorschemes) do
            if string.match(current_colorscheme, c.pattern) then
                local highlights = opts.customizations[name]

                if highlights then
                    apply_customizations(name, highlights)
                    break
                end
            end
        end
    end

    vim.api.nvim_create_autocmd('ColorScheme', {
        group    = 'CustomHighlights',
        pattern  = "*",
        desc     = "Apply links, and potential customizations",
        callback = apply
    })
end

return M
