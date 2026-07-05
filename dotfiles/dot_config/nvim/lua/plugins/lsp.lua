return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "nvim-web-devicons",
    },
    opts = {
      ensure_installed = {
        "csharp_ls",
        "docker_compose_language_service",
        "dockerls",
        "eslint",
        "gitlab_ci_ls",
        "html",
        "jsonls",
        "lua_ls",
        "marksman",
        "openscad_lsp",
        "postgres_lsp",
        "prismals",
        "svelte",
        "tailwindcss",
        "tinymist",
        "ts_ls",
        "yamlls",
      },
    },
    config = function(_, opts)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            env = {
              CGO_ENABLED = "1",
            },
            completeUnimported = true,
            staticcheck = true,
            analyses = { unusedparams = true },
          },
        },
      })

      vim.lsp.config("gdscript", {
        cmd = { "nc", "127.0.0.1", "6005" },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemas = {
              kubernetes = "*.yaml",
              ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
              ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
            },
          },
        },
      })

      vim.lsp.enable({ "gopls", "gdscript", "clangd", "pylsp", "bashls" })

      require("mason-lspconfig").setup(opts)
    end,
  },

  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    config = function()
      require("lsp_lines").setup()
    end,
  },
}
