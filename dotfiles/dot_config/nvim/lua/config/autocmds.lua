local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yank region briefly
augroup("highlight_yank", { clear = true })
autocmd("TextYankPost", {
  group = "highlight_yank",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Restore cursor position on file open
augroup("restore_cursor", { clear = true })
autocmd("BufReadPost", {
  group = "restore_cursor",
  pattern = "*",
  callback = function()
    if
      vim.fn.line("'\"") > 1
      and vim.fn.line("'\"") <= vim.fn.line("$")
      and vim.bo.filetype ~= "commit"
      and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
    then
      vim.cmd("normal! g`\"")
    end
  end,
})

-- ESLint fix before conform format_on_save
augroup("eslint_fix", { clear = true })
autocmd("BufWritePre", {
  group = "eslint_fix",
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx", "*.svelte" },
  callback = function(args)
    local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "eslint" })
    if #clients == 0 then return end

    local client = clients[1]
    local diag_params = {
      textDocument = vim.lsp.util.make_text_document_params(args.buf),
      context = { only = { "source.fixAll.eslint" }, diagnostics = {} },
    }
    local result = client:request_sync("textDocument/codeAction", diag_params, 3000, args.buf)
    if not result or not result.result then return end

    for _, action in ipairs(result.result) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding or "utf-16")
      elseif action.command then
        vim.lsp.buf.execute_command(action.command)
      end
    end
  end,
})

-- Disable treesitter on large buffers (>5000 lines)
augroup("large_buffer", { clear = true })
autocmd("BufReadPost", {
  group = "large_buffer",
  pattern = "*",
  callback = function(args)
    if vim.api.nvim_buf_line_count(args.buf) > 5000 then
      vim.treesitter.stop(args.buf)
    end
  end,
})

-- Filetype overrides
vim.filetype.add({
  extension = {
    FCMacro = "python",
    FCScript = "python",
    FCMat = "yaml",
    FCParam = "xml",
    fctb = "json",
    fctl = "json",
  },
  filename = {
    [".prettierrc"] = "json",
    [".eslintrc"] = "json",
  },
})

-- Godot: start server pipe if in a godot project
local function find_godot_project_root()
  local cwd = vim.fn.getcwd()
  for _, rel in ipairs({ "", "/.." }) do
    local project_file = cwd .. rel .. "/project.godot"
    if vim.uv.fs_stat(project_file) then
      return cwd .. rel
    end
  end
end

local function start_godot_server_if_needed()
  local root = find_godot_project_root()
  if root and not vim.uv.fs_stat(root .. "/server.pipe") then
    vim.fn.serverstart(root .. "/server.pipe")
  end
end

start_godot_server_if_needed()

-- conform: user commands for toggling autoformat
local slow_format_filetypes = {}
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, { desc = "Disable autoformat-on-save", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, { desc = "Re-enable autoformat-on-save" })

vim.api.nvim_create_user_command("FormatToggle", function(args)
  if args.bang then
    vim.b.disable_autoformat = not vim.b.disable_autoformat
  else
    vim.g.disable_autoformat = not vim.g.disable_autoformat
  end
end, { desc = "Toggle autoformat-on-save", bang = true })

-- expose slow_format_filetypes for conform plugin to reference
_G.slow_format_filetypes = slow_format_filetypes
