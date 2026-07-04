return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-web-devicons",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = {
        bashls = {},
        clangd = {},
        csharp_ls = {},
        docker_compose_language_service = {},
        dockerls = {},
        eslint = {},
        gitlab_ci_ls = {},
        html = {},
        jsonls = {},
        lua_ls = {},
        marksman = {},
        postgres_lsp = {},
        prismals = {},
        pylsp = {},
        svelte = {},
        tailwindcss = {},
        tinymist = {},
        ts_ls = {},
        openscad_lsp = { autostart = true },
        gopls = {
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
        },
        gdscript = {
          cmd = { "nc", "127.0.0.1", "6005" },
        },
        nixd = {
          settings = {
            nixd = {
              formatting = { command = { "alejandra" } },
            },
          },
        },
        yamlls = {
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
        },
      }

      for server, config in pairs(servers) do
        config.capabilities = capabilities
        lspconfig[server].setup(config)
      end
    end,
  },

  {
    "https://git.sr.ht/~whynothugo/lsp-lines.nvim",
    event = "LspAttach",
    config = function()
      require("lsp_lines").setup()
    end,
  },
}
