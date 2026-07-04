return {
  {
    "echasnovski/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.basics").setup({ options = { extra_ui = true } })
      require("mini.indentscope").setup()
      require("mini.pick").setup()
      require("mini.surround").setup()
    end,
  },
}
