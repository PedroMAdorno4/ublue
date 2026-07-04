return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_browser = "firefox"
      vim.g.mkdp_port = "8099"
      vim.g.mkdp_page_title = "「${name}」"
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_preview_options = { sync_scroll_type = "middle" }
    end,
  },
}
