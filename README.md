# highlights-nvim

Customize Neovim highlight groups across colorschemes. Highlights are automatically reapplied when you switch colorschemes.

### Why?

This plugin serves as a unified interface towards keeping a tidy and customizable look across different colorschemes, without fine-tuning every schemes colors manually. Have a look at the example setups for inspiration on what this can be used for!

## Install

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
    "viktoraxen/highlights-nvim",
    opts = {
        links = { ... },
        customizations = { ... },
    },
}
```

## Examples

### Make floating windows match your background

Use `links` to make one highlight group inherit from another:

```lua
opts = {
    links = {
        ["*"] = {
            NormalFloat = "Normal",
            FloatBorder = "Normal",
        },
    },
}
```

### Change colors for a specific colorscheme

Use the colorscheme name as a key. For Catppuccin and Tokyonight, you can reference palette color names directly:

```lua
opts = {
    customizations = {
        catppuccin = {
            WinSeparator = { fg = "crust", bg = "surface0" },
        },
        tokyonight = {
            LineNr = { fg = "#565f89" },
        },
    },
}
```

Palette references:
- **[Catppuccin](https://github.com/catppuccin/nvim)** — [palette](https://catppuccin.com/palette/)
- **[Tokyonight](https://github.com/folke/tokyonight.nvim)** — run `:lua print(vim.inspect(require("tokyonight.colors").setup()))` to list colors

### Use any other colorscheme

Any colorscheme name works as a key — just use hex colors instead of palette names:


```lua
opts = {
    customizations = {
        gruvbox = {
            WinSeparator = { fg = "#928374", bg = "#282828" },
        },
    },
}
```

To use palette names with other colorschemes, register them through the `colorschemes` field:

```lua
opts = {
    colorschemes = {
        gruvbox = {
            pattern = "gruvbox*",
            palette = function()
                return {
                    bg0    = "#282828",
                    fg0    = "#fbf1c7",
                    red    = "#cc241d",
                    green  = "#98971a",
                }
            end,
        },
    },
    customizations = {
        gruvbox = {
            WinSeparator = { fg = "bg0" },
            Comment = { fg = "green" },
        },
    },
}
```

`pattern` controls which colorscheme names activate this entry (e.g. `"gruvbox*"` matches `gruvbox`, `gruvbox-material`, etc.). `palette` returns a table of names to hex colors — you can define these inline or load them from the colorscheme's own module.

### Remove italic from comments

Set any attribute to `false` to remove it:

```lua
opts = {
    customizations = {
        ["*"] = {
            Comment = { italic = false },
        },
    },
}
```

### Blend two colors together

Use the `"color_a|color_b|amount"` syntax. `amount` controls how much of `color_a` to mix in (`0` = all `color_b`, `1` = all `color_a`, default `0.5`). Each side can be a hex color, palette name, or highlight group name.

```lua
opts = {
    customizations = {
        catppuccin = {
            -- Darken Normal's foreground
            Comment = { fg = "Normal|#000000|0.3" },
            -- Mix two palette colors
            CursorLine = { bg = "base|surface0|0.5" },
        },
    },
}
```

### Borrow a color from another highlight group

Use a highlight group name as a color value to copy its `fg` or `bg`:

```lua
opts = {
    customizations = {
        ["*"] = {
            StatusLine = { bg = "Normal" },
        },
    },
}
```

### Auto-contrast based on dark/light background

Use `"contrast"` to get black on dark backgrounds and white on light ones:

```lua
opts = {
    customizations = {
        ["*"] = {
            CursorLineNr = { fg = "contrast" },
        },
    },
}
```

### Apply different settings per colorscheme with shared defaults

`"*"` entries apply to all colorschemes. Per-scheme entries override them:

```lua
opts = {
    links = {
        ["*"] = {
            NormalFloat = "Normal",
        },
        catppuccin = {
            FloatBorder = "Title",
        },
    },
    customizations = {
        ["*"] = {
            Comment = { italic = false },
        },
        catppuccin = {
            WinSeparator = { fg = "crust" },
        },
    },
}
```

### Add highlights from another plugin's config

Use `require("highlights-nvim").add()` to merge configuration from anywhere:

```lua
require("highlights-nvim").add({
    links = {
        ["*"] = { TelescopeBorder = "FloatBorder" },
    },
    customizations = {
        catppuccin = {
            TelescopeNormal = { bg = "mantle" },
        },
    },
})
```

## Color value reference

| Value | Example | What it does |
| --- | --- | --- |
| Hex color | `"#ff5555"` | Use this exact color |
| Palette name | `"crust"` | Look up from the colorscheme palette |
| Highlight group | `"Normal"` | Use that group's `fg` or `bg` |
| Blend | `"Normal\|#000000\|0.7"` | Mix two colors together |
| `"contrast"` | `"contrast"` | Black on dark backgrounds, white on light |
| `false` | `false` | Remove the attribute |
