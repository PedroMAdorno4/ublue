return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-web-devicons" },
    opts = {
      skip_confirm_for_simple_edits = true,
      view_options = { show_hidden = true },
      win_options = {
        winbar = "%!v:lua.get_oil_winbar()",
      },
    },
    config = function(_, opts)
      require("oil").setup(opts)

      function _G.get_oil_winbar()
        local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
        local dir = require("oil").get_current_dir(bufnr)
        if dir then
          return vim.fn.fnamemodify(dir, ":~")
        else
          return vim.api.nvim_buf_get_name(0)
        end
      end
    end,
  },
}
