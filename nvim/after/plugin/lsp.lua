local lsp_zero = require("lsp-zero")

lsp_zero.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	vim.keymap.set("n", "gd", function()
		vim.lsp.buf.definition()
	end, opts)
	vim.keymap.set("n", "K", function()
		vim.lsp.buf.hover()
	end, opts)
	vim.keymap.set("n", "<leader>vws", function()
		vim.lsp.buf.workspace_symbol()
	end, opts)
	vim.keymap.set("n", "<leader>vd", function()
		vim.diagnostic.open_float()
	end, opts)
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.goto_next()
	end, opts)
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.goto_prev()
	end, opts)
	vim.keymap.set("n", "<leader>vca", function()
		vim.lsp.buf.code_action()
	end, opts)
	vim.keymap.set("n", "<leader>vrr", function()
		vim.lsp.buf.references()
	end, opts)
	vim.keymap.set("n", "<leader>vrn", function()
		vim.lsp.buf.rename()
	end, opts)
	vim.keymap.set("i", "<C-h>", function()
		vim.lsp.buf.signature_help()
	end, opts)
end)

require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = { "tsserver", "rust_analyzer", "pyright", "eslint", "lua_ls", "efm", "gopls" },
	handlers = {
		lsp_zero.default_setup,
		-- lua_ls = function()
		-- local lua_opts = lsp_zero.nvim_lua_ls()
		-- require("lspconfig").lua_ls.setup(lua_opts)
		-- end,
		lua_ls = require("lspconfig").lua_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = { -- custom settings for lua
				Lua = {
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						-- make language server aware of runtime files
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
				},
			},
		}),

		python = require("lspconfig").pyright.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				pyright = {
					completeUnimported = true,
					disableOrganizeImports = false,
					usePlaceholders = true,
					analysis = {
						useLibraryCodeForTypes = true,
						autoSearchPaths = true,
						diagnosticMode = "workspace",
						autoImportCompletions = true,
						unusedparams = true,
					},
				},
			},
		}),

		type_script = require("lspconfig").tsserver.setup({

			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = {
				"typescript",
			},
			root_dir = require("lspconfig").util.root_pattern("package.json", "tsconfig.json", ".git"),
		}),

		go = require("lspconfig").gopls.setup({

			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = {
				"go",
				"gomod",
				"gowork",
				"gotmpl",
			},
			root_dir = require("lspconfig").util.root_pattern("go.work", "go.mod", ".git"),
			settings = {
				gopls = {
					completeUnimported = true,
					usePlaceholders = true,
					analyses = {
						unusedparams = true,
					},
				},
			},
		}),

		efm = require("lspconfig").efm.setup({
			filetypes = { "lua", "python", "rust", "go", "javascript", "typescript", "bash", "html", "css", "c", "cpp" },

			init_options = {
				documentFormatting = true,
				documentRangeFormatting = true,
				hover = true,
				documentSymbol = true,
				codeAction = true,
				completion = true,
			},
			settings = {

				rootMarkers = { ".git/" },
				languages = {
					lua = {
						require("efmls-configs.linters.luacheck"),
						require("efmls-configs.formatters.stylua"),
					},
					python = {
						require("efmls-configs.linters.ruff"),
						require("efmls-configs.linters.mypy"),
						require("efmls-configs.formatters.ruff"),
						require("efmls-configs.formatters.isort"),
					},
					typescript = {
						require("efmls-configs.linters.eslint_d"),
						require("efmls-configs.formatters.prettier_d"),
					},
					go = {

						require("efmls-configs.linters.golangci_lint"),
						require("efmls-configs.formatters.gofumpt"),
						require("efmls-configs.formatters.goimports"),
						require("efmls-configs.formatters.golines"),
					},
				},
			},
		}),
	},
})

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
	sources = {
		{ name = "path" },
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
	},
	formatting = lsp_zero.cmp_format(),
	mapping = cmp.mapping.preset.insert({
		["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
		["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<C-Space>"] = cmp.mapping.complete(),
	}),
})
-- Format on save
local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
vim.api.nvim_create_autocmd("BufWritePost", {
	group = lsp_fmt_group,
	callback = function()
		local efm = vim.lsp.get_active_clients({ name = "efm" })
		if vim.tbl_isempty(efm) then
			return
		end
		vim.lsp.buf.format({ name = "efm", async = true })
	end,
})
