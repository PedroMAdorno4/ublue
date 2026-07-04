local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = false, desc = desc })
end

-- File explorer
map("n", "<leader>e", ":Oil<CR>", "Open file explorer")

-- Clear search highlights
map("n", "<esc>", ":noh<CR>", "Clear search highlights")

-- Yank to end of line
map("n", "Y", "y$", "Yank to EOL")

-- Switch to last buffer
map("n", "<C-c>", ":b#<CR>", "Switch to last buffer")

-- Undotree
map("n", "<leader>u", ":UndotreeToggle<CR>", "Toggle undotree")

-- Mini.pick
map("n", "<leader>ff", ":Pick files<CR>", "Find files")
map("n", "<leader>fw", ":Pick grep_live<CR>", "Live grep")
map("n", "<leader>h", ":Pick help<CR>", "Help tags")
map("n", "<leader>'", ":Pick resume<CR>", "Resume last pick")

-- Resize splits
map("n", "<C-Up>", ":resize -2<CR>", "Shrink split height")
map("n", "<C-Down>", ":resize +2<CR>", "Grow split height")
map("n", "<C-Left>", ":vertical resize +2<CR>", "Grow split width")
map("n", "<C-Right>", ":vertical resize -2<CR>", "Shrink split width")

-- LSPSaga
map("n", "gd", "<cmd>Lspsaga finder def<CR>", "Go to definition")
map("n", "gr", "<cmd>Lspsaga finder ref<CR>", "Go to references")
map("n", "gi", "<cmd>Lspsaga finder imp<CR>", "Go to implementation")
map("n", "gT", "<cmd>Lspsaga peek_type_definition<CR>", "Peek type definition")
map("n", "K", "<cmd>Lspsaga hover_doc<CR>", "Hover doc")
map("n", "<leader>lf", ":lua require('conform').format({ async = true })<CR>", "Format buffer")
map("n", "<leader>lo", "<cmd>Lspsaga outline<CR>", "Symbol outline")
map("n", "<leader>lr", "<cmd>Lspsaga rename<CR>", "Rename symbol")
map("n", "<leader>la", "<cmd>Lspsaga code_action<CR>", "Code action")
map("n", "<leader>lA", ':lua require("actions-preview").code_actions()<CR>', "Code actions (preview)")
map("n", "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", "Show diagnostics")
map("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", "Next diagnostic")
map("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Prev diagnostic")

-- Move lines
map("n", "<M-k>", ":move-2<CR>", "Move line up")
map("n", "<M-j>", ":move+<CR>", "Move line down")

-- LazyGit
map("n", "<leader>gs", ":LazyGit<CR>", "Open LazyGit")

-- Visual mode: move selected block
map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")
map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")
