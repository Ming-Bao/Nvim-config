-- Global helper library (lua/util/), used by the plugin specs and keymaps.
_G.Util = require("util")

-- delay notifications till vim.notify was replaced (by snacks) or after 500ms
Util.lazy_notify()

require("config.options")
require("config.autocmds")

-- keymaps need Snacks (toggles, terminal, pickers), so load them once everything is ready
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("config.keymaps")
    Util.format.setup()
    Util.root.setup()
  end,
})

require("config.lazy")
