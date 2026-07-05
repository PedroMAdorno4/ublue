return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        floats = "dark",
        sidebars = "dark",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd("colorscheme tokyonight")

      -- Material You accents from matugen, generated at ~/.config/nvim/lua/colors.lua.
      -- Not present before matugen's first run, so this fails quietly until then.
      local ok, colors = pcall(require, "colors")
      if not ok then
        return
      end

      vim.api.nvim_set_hl(0, "CursorLine", { bg = colors.surface_container_high })
      vim.api.nvim_set_hl(0, "Visual", { bg = colors.secondary_container, fg = colors.on_secondary_container })
      vim.api.nvim_set_hl(0, "Search", { bg = colors.tertiary_container, fg = colors.on_tertiary_container })
      vim.api.nvim_set_hl(0, "IncSearch", { bg = colors.tertiary, fg = "#000000" })
      vim.api.nvim_set_hl(0, "StatusLine", { bg = colors.primary_container, fg = colors.on_primary_container })
      vim.api.nvim_set_hl(0, "Pmenu", { bg = colors.surface_container_high })
      vim.api.nvim_set_hl(0, "PmenuSel", { bg = colors.primary, fg = colors.on_primary })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.primary })
      vim.api.nvim_set_hl(0, "MatchParen", { bg = colors.outline })
      vim.api.nvim_set_hl(0, "ErrorMsg", { fg = colors.error })
    end,
  },
}
