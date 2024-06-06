require("nvim-ts-autotag").setup()

require("lualine").setup({
	sections = { lualine_a = { "mode", "buffers" } },
})
