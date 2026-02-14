# highlights-nvim

A Neovim plugin for configuring highlight groups. Link highlights to each other, customize colors per colorscheme, and blend colors together — all from a single configuration table.

Highlights are automatically reapplied whenever you change your colorscheme.

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

## Configuration

The plugin accepts two top-level fields: `links` and `customizations`.

Both support **global** entries under the `"*"` key (applied to every colorscheme) and **per-scheme** entries that only apply when the matching colorscheme is active. Per-scheme entries override global ones.

### Links

Link one highlight group to another. Useful for making groups like `NormalFloat` inherit from `Normal`.

**Global links** (apply to all colorschemes):

```lua
opts = {
    links = {
        ["*"] = {
            NormalFloat = "Normal",
            FloatBorder = "Title",
        },
    },
}
```

**Per-scheme links** (only apply when that colorscheme is active):

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
}
```

### Customizations

Set specific attributes (`fg`, `bg`, `bold`, `italic`, etc.) on highlight groups. Omitted attributes are left unchanged.

```lua
opts = {
    customizations = {
        catppuccin = {
            WinSeparator = { fg = "crust", bg = "surface0", italic = false },
        },
        tokyonight = {
            Normal = { fg = "#c0caf5" },
        },
        ["*"] = {
            Visual = { bg = "#3b4261" },
        },
    },
}
```

### Color values

Colors in customizations can be specified in several ways:

| Format | Example | Description |
| --- | --- | --- |
| Hex string | `"#ff5555"` | A literal hex color |
| Palette name | `"crust"` | A named color from the active colorscheme's palette |
| Highlight group | `"Normal"` | Copies the matching attribute (`fg` or `bg`) from that group |
| Blend expression | `"Normal\|#000000\|0.7"` | Blends two colors together (see [Blending](#blending)) |
| `"contrast"` | `"contrast"` | Resolves to `#000000` on dark backgrounds, `#ffffff` on light |
| `false` | `false` | Removes the attribute entirely |

### Blending

The blend syntax is `"color_a|color_b|amount"` where `amount` is a number between `0` and `1`. At `0` you get `color_b`; at `1` you get `color_a`. If omitted, `amount` defaults to `0.5`.

Each side of the blend can itself be any color value (hex, palette name, or highlight group).

```lua
customizations = {
    catppuccin = {
        -- Blend Normal's foreground 70% toward black
        Comment = { fg = "Normal|#000000|0.3" },
        -- Blend two palette colors equally
        CursorLine = { bg = "base|surface0|0.5" },
    },
}
```

### Removing attributes

Set an attribute to `false` to remove it from the resolved highlight:

```lua
customizations = {
    ["*"] = {
        Comment = { italic = false },
    },
}
```

## Supported colorschemes

The following colorschemes have built-in palette support, meaning you can reference palette color names directly in your customizations:

- **[Catppuccin](https://github.com/catppuccin/nvim)** — [palette reference](https://catppuccin.com/palette/)
- **[Tokyonight](https://github.com/folke/tokyonight.nvim)** — run `:lua print(vim.inspect(require("tokyonight.colors").setup()))` to see available names

For any other colorscheme, you can still use hex colors, highlight group references, blending, and `"contrast"` — palette names are the only feature that requires built-in support.

## API

### `require("highlights-nvim").add(opts)`

Merge additional configuration and apply it immediately. Useful for adding highlights from other plugin configs:

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

### `require("highlights-nvim").apply_highlights()`

Reapply all configured links and customizations. Called automatically on every `ColorScheme` event — you normally don't need to call this yourself.
