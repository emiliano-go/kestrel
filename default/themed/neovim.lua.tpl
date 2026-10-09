return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    opts = {
      style = "night",
      on_colors = function(colors)
        colors.bg = "{{ background }}",
        colors.bg_dark = "{{ dark_background }}",
        colors.bg_float = "{{ darker_background }}",
        colors.bg_highlight = "{{ lighter_background }}",
        colors.fg = "{{ foreground }}",
        colors.fg_dark = "{{ dark_foreground }}",
        colors.fg_gutter = "{{ muted }}",
        colors.comment = "{{ muted }}",
        colors.red = "{{ red }}",
        colors.green = "{{ green }}",
        colors.yellow = "{{ yellow }}",
        colors.blue = "{{ blue }}",
        colors.magenta = "{{ magenta }}",
        colors.cyan = "{{ cyan }}",
        colors.orange = "{{ orange }}",
        colors.purple = "{{ magenta }}",
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
