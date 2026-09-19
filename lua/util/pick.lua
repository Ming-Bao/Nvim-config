-- Root-dir aware wrapper around the snacks picker.
-- Util.pick("files") returns a function that opens the picker in the project root,
-- Util.pick("files", { root = false }) uses the cwd instead.
---@class util.pick
---@overload fun(command:string, opts?:util.pick.Opts): fun()
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.wrap(...)
  end,
})

---@class util.pick.Opts: table<string, any>
---@field root? boolean
---@field cwd? string
---@field buf? number

-- names used in the specs -> snacks picker sources
M.commands = {
  files = "files",
  live_grep = "grep",
  oldfiles = "recent",
}

---@param command? string
---@param opts? util.pick.Opts
function M.open(command, opts)
  command = command ~= "auto" and command or "files"
  opts = vim.deepcopy(opts or {})

  if not opts.cwd and opts.root ~= false then
    opts.cwd = Util.root({ buf = opts.buf })
  end

  command = M.commands[command] or command
  Snacks.picker.pick(command, opts)
end

---@param command? string
---@param opts? util.pick.Opts
function M.wrap(command, opts)
  opts = opts or {}
  return function()
    Util.pick.open(command, vim.deepcopy(opts))
  end
end

function M.config_files()
  return M.wrap("files", { cwd = vim.fn.stdpath("config") })
end

return M
