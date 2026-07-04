return {
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = { "nvim-web-devicons" },
    opts = {
      beacon = { enable = true },
      ui = {
        border = "rounded",
        code_action = "💡",
      },
      hover = {
        open_cmd = "!firefox",
        open_link = "gx",
      },
      diagnostic = {
        border_follow = true,
        diagnostic_only_current = false,
        show_code_action = true,
      },
      symbol_in_winbar = { enable = true },
      code_action = {
        extend_gitsigns = false,
        show_server_name = true,
        only_in_cursor = false,
        num_shortcut = true,
        keys = {
          exec = "<CR>",
          quit = { "<Esc>", "q" },
        },
      },
      lightbulb = {
        enable = false,
        sign = false,
        virtual_text = true,
      },
      implement = { enable = true },
      rename = {
        auto_save = false,
        keys = {
          exec = "<CR>",
          quit = { "<Esc>", "q" },
          select = "x",
        },
      },
      outline = {
        auto_close = true,
        auto_preview = true,
        close_after_jump = true,
        layout = "normal",
        win_position = "right",
        keys = {
          jump = "e",
          quit = { "<Esc>", "q" },
          toggle_or_jump = "o",
        },
      },
      scroll_preview = {
        scroll_down = "<C-d>",
        scroll_up = "<C-u>",
      },
    },
  },
}
