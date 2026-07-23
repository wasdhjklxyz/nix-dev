local plugin = assert(vim.env.NVIM_DEV_PLUGIN, "NVIM_DEV_PLUGIN not set")
local name = vim.fs.basename(plugin)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { dir = plugin, name = name, opts = {} },
}, {
  change_detection = { enabled = false },
  rocks = { enabled = false },
})

vim.keymap.set("n", "<leader>r", function()
  require("lazy").reload({ plugins = { name } })
end, { desc = "reload " .. name })
