return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        if _G.slow_format_filetypes and _G.slow_format_filetypes[vim.bo[bufnr].filetype] then
          return
        end
        local function on_format(err)
          if err and err:match("timeout$") then
            if _G.slow_format_filetypes then
              _G.slow_format_filetypes[vim.bo[bufnr].filetype] = true
            end
          end
        end
        return { timeout_ms = 1000, lsp_format = "fallback", quiet = false }, on_format
      end,
      format_after_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        if not (_G.slow_format_filetypes and _G.slow_format_filetypes[vim.bo[bufnr].filetype]) then
          return
        end
        return { lsp_fallback = true }
      end,
      formatters_by_ft = {
        html       = { "prettierd", "prettier", timeout_ms = 2000, stop_after_first = true },
        css        = { "prettierd", "prettier", timeout_ms = 2000, stop_after_first = true },
        javascript = { "prettierd", "prettier", timeout_ms = 2000, stop_after_first = true },
        typescript = { "prettierd", "prettier", timeout_ms = 2000, stop_after_first = true },
        markdown   = { "prettierd", "prettier", timeout_ms = 2000, stop_after_first = true },
        yaml       = { "prettierd", "prettier", timeout_ms = 2000, stop_after_first = true },
        python     = { "ruff" },
        lua        = { "stylua" },
        nix        = { "alejandra" },
        bash       = { "shellcheck", "shellharden", "shfmt" },
        json       = { "jq" },
        rust       = { "rustfmt" },
        dart       = { "dart_format" },
        ["_"]      = { "trim_whitespace" },
      },
    },
  },
}
