vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.updatetime = 100
opt.relativenumber = true
opt.number = true
opt.wrap = false
opt.splitbelow = true
opt.splitright = true
opt.undofile = true
opt.incsearch = true
opt.inccommand = "split"
opt.ignorecase = true
opt.smartcase = true
opt.scrolloff = 12
opt.cursorline = false
opt.signcolumn = "no"
opt.fileencoding = "utf-8"
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.mouse = ""
opt.completeopt = { "menu", "menuone", "noselect" }
opt.winborder = "rounded"
opt.clipboard = "unnamedplus"
