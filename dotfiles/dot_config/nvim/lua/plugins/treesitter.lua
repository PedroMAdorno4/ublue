return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(ev)
          local ts = require("nvim-treesitter")
          local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
          if not require("nvim-treesitter.parsers")[lang] then
            return
          end

          if not vim.list_contains(ts.get_installed("parsers"), lang) then
            ts.install(lang)
          end

          vim.treesitter.start()
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo.foldmethod = "expr"
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
