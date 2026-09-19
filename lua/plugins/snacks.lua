-- snacks.nvim: a collection of small plugins. This one spec powers the picker (find/grep/lsp),
-- file explorer, notifications, terminal, scratch buffers, indent guides, and more.
-- To cut a part (e.g. the notifier), delete its entry in `opts` and any keys that use it.

-- Terminal Mappings
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- utils
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    terminal = {
      win = {
        keys = {
          nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
          nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
          nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
          nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
          hide_slash = { "<C-/>", "hide", desc = "Hide Terminal", mode = "t" },
          hide_underscore = { "<c-_>", "hide", desc = "which_key_ignore", mode = "t" },
        },
      },
    },

    -- ui
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = false }, -- we set this in config/options.lua
    toggle = { map = Util.safe_keymap_set },
    words = { enabled = true },

    -- file explorer (<leader>e)
    explorer = {},

    -- picker (find files, grep, lsp, git, ...)
    picker = {
      win = {
        input = {
          keys = {
            ["<a-c>"] = {
              "toggle_cwd",
              mode = { "n", "i" },
            },
            ["<a-t>"] = {
              "trouble_open",
              mode = { "n", "i" },
            },
            -- flash.nvim integration
            ["<a-s>"] = { "flash", mode = { "n", "i" } },
            ["s"] = { "flash" },
          },
        },
      },
      actions = {
        ---@param p snacks.Picker
        toggle_cwd = function(p)
          local root = Util.root({ buf = p.input.filter.current_buf, normalize = true })
          local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
          local current = p:cwd()
          p:set_cwd(current == root and cwd or root)
          p:find()
        end,
        trouble_open = function(...)
          return require("trouble.sources.snacks").actions.trouble_open.action(...)
        end,
        flash = function(picker)
          require("flash").jump({
            pattern = "^",
            label = { after = { 0, 0 } },
            search = {
              mode = "search",
              exclude = {
                function(win)
                  return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                end,
              },
            },
            action = function(match)
              local idx = picker.list:row2idx(match.pos[1])
              picker.list:_move(idx, true, true)
            end,
          })
        end,
      },
    },
  },
  config = function(_, opts)
    local notify = vim.notify
    require("snacks").setup(opts)
    -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
    -- this is needed to have early notifications show up in noice history
    if Util.has("noice.nvim") then
      vim.notify = notify
    end
  end,
  -- stylua: ignore
  keys = {
    -- scratch buffers
    { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },

    -- notifications
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },

    -- explorer
    { "<leader>fe", function() Snacks.explorer({ cwd = Util.root() }) end, desc = "Explorer Snacks (root dir)" },
    { "<leader>fE", function() Snacks.explorer() end, desc = "Explorer Snacks (cwd)" },
    { "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
    { "<leader>E", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },

    -- picker
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>/", Util.pick("grep"), desc = "Grep (Root Dir)" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader><space>", Util.pick("files"), desc = "Find Files (Root Dir)" },
    -- find
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = "Buffers (all)" },
    { "<leader>fc", Util.pick.config_files(), desc = "Find Config File" },
    { "<leader>ff", Util.pick("files"), desc = "Find Files (Root Dir)" },
    { "<leader>fF", Util.pick("files", { root = false }), desc = "Find Files (cwd)" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Files (git-files)" },
    { "<leader>fr", Util.pick("oldfiles"), desc = "Recent" },
    { "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "Recent (cwd)" },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
    -- git
    { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (hunks)" },
    { "<leader>gD", function() Snacks.picker.git_diff({ base = "origin", group = true }) end, desc = "Git Diff (origin)" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
    { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
    { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
    { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
    { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },
    -- Grep
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
    { "<leader>sg", Util.pick("live_grep"), desc = "Grep (Root Dir)" },
    { "<leader>sG", Util.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
    { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
    { "<leader>sw", Util.pick("grep_word"), desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
    { "<leader>sW", Util.pick("grep_word", { root = false }), desc = "Visual selection or word (cwd)", mode = { "n", "x" } },
    -- search
    { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
    { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
    { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
    { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
    { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
    { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "Undotree" },
    -- ui
    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
  },
}
