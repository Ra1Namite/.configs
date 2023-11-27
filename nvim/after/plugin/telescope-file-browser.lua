require("telescope").load_extension "file_browser"
vim.api.nvim_set_keymap(
  "n",
  "<space>fB",
  ":Telescope file_browser<CR>",
  { noremap = true }
) -- open file browser from root of project.

-- open file_browser with the path of the current buffer
vim.api.nvim_set_keymap(
  "n",
  "<space>cfb",
  ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { noremap = true }
)
