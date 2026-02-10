local utils = require("highlights-nvim.utils")

local M = {}

M.config = {
    colorschemes = {
        catppuccin = {
            pattern = "catppuccin*",
            palette = function()
                return require("catppuccin.palettes").get_palette()
            end,
        },
        tokyonight = {
            pattern = "tokyonight*",
            palette = function()
                return require("tokyonight.colors").setup()
            end,
        },
    },
    customizations = {},
    links = {},
}

local function deep_merge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == 'table' and type(t1[k]) == 'table' then
            deep_merge(t1[k], v)
        else
            t1[k] = v
        end
    end

    return t1
end

local function scheme_is_active(name)
    local current = vim.g.colors_name or ""
    local cs = M.config.colorschemes[name]
    local pattern = cs and cs.pattern or (name .. "*")
    return vim.fn.match(current, vim.fn.glob2regpat(pattern)) ~= -1
end

local function load_palette(name)
    local cs = M.config.colorschemes[name]
    if not cs or not cs.palette then return nil end

    local ok, result = pcall(cs.palette)
    if ok then return result end

    vim.notify(
        string.format("highlights-nvim: Failed to load palette for %q: %s", name, result),
        vim.log.levels.WARN
    )
    return nil
end

local function resolve_color(group, hl, palette)
    local function resolve_attr(id, attr)
        if not id then return nil end

        if string.match(id, "^#") then
            return id
        end

        if id == "contrast" then
            return vim.o.background == "dark" and "#000000" or "#ffffff"
        end

        if string.find(id, "|", 1, true) then
            local parts = vim.split(id, "|")
            local a = resolve_attr(parts[1], attr)
            local b = resolve_attr(parts[2], attr)
            local amount = tonumber(parts[3]) or 0.5

            if a and b then return utils.blend(a, b, amount) end
            return a or b
        end

        if palette and palette[id] then
            return palette[id]
        end

        local hl_group = utils.get_hl(id)
        if hl_group[attr] then
            return string.format("#%06x", hl_group[attr])
        end

        if palette then
            vim.notify(string.format("highlights-nvim: Could not resolve color %q", id), vim.log.levels.WARN)
        end
        return nil
    end

    local resolved = {}
    for k, v in pairs(hl) do
        resolved[k] = v
    end

    local current_hl = utils.get_hl(group)

    current_hl.bg = current_hl.bg and string.format("#%06x", current_hl.bg)
    current_hl.fg = current_hl.fg and string.format("#%06x", current_hl.fg)

    resolved.fg = resolved.fg and resolve_attr(resolved.fg, "fg")
    resolved.bg = resolved.bg and resolve_attr(resolved.bg, "bg")

    return vim.tbl_deep_extend("force", current_hl, resolved)
end

local function apply_scheme_customizations(groups, palette)
    for group, hl in pairs(groups) do
        local new_hl = resolve_color(group, hl, palette)

        if new_hl then
            vim.api.nvim_set_hl(0, group, new_hl)
        else
            vim.notify(string.format("highlights-nvim: Could not resolve highlight for %q", group),
                vim.log.levels.WARN)
        end
    end
end

local function apply_customizations(customizations)
    -- Apply global customizations first
    if customizations["*"] then
        apply_scheme_customizations(customizations["*"], nil)
    end

    -- Apply scheme-specific customizations (overrides globals)
    for scheme, groups in pairs(customizations) do
        if scheme ~= "*" and scheme_is_active(scheme) then
            local palette = load_palette(scheme)
            apply_scheme_customizations(groups, palette)
        end
    end
end

local function apply_links(links)
    -- Apply global links first
    if links["*"] then
        for src, dst in pairs(links["*"]) do
            vim.api.nvim_set_hl(0, src, { link = dst })
        end
    end

    -- Apply scheme-specific links (overrides globals)
    for scheme, scheme_links in pairs(links) do
        if scheme ~= "*" and scheme_is_active(scheme) then
            for src, dst in pairs(scheme_links) do
                vim.api.nvim_set_hl(0, src, { link = dst })
            end
        end
    end
end

M.apply_highlights = function()
    apply_links(M.config.links)
    apply_customizations(M.config.customizations)
end

M.add = function(opts)
    if not opts then return end

    M.config = deep_merge(M.config, opts)

    M.apply_highlights()
end

return M
