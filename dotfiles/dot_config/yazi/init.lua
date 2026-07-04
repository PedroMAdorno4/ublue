require("whoosh"):setup({
  keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
  special_keys = {
    create_temp   = "<Enter>",
    fuzzy_search  = "<Space>",
    history       = "<Tab>",
    previous_dir  = "<Backspace>",
    project_root  = "-",
  },
  bookmarks_path = (os.getenv("HOME") .. "/.local/share/yazi/bookmarks"),
  home_alias_enabled = true,
})
