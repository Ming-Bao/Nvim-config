-- Treesitter is a new parser generator tool that we can
-- use in Neovim to power faster and more accurate
-- syntax highlighting.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  version = false, -- last release is way too old and doesn't work on Windows
  build = function()
    local TS = require("nvim-treesitter")
    if not TS.get_installed then
      Util.error("Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch.")
      return
    end
    -- make sure we're using the latest treesitter util
    package.loaded["util.treesitter"] = nil
    Util.treesitter.build(function()
      TS.update(nil, { summary = true })
    end)
  end,
  event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
  cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
  ---@alias TSFeat { enable?: boolean, disable?: string[] }
  ---@class TSConfig: TSConfig
  opts = {
    -- treesitter features (per-language opt-out with `disable = { "lang" }`)
    indent = { enable = true }, ---@type TSFeat
    highlight = { enable = true }, ---@type TSFeat
    folds = { enable = true }, ---@type TSFeat
    ensure_installed = {
      "bash",
      "c",
      "diff",
      "html",
      "javascript",
      "jsdoc",
      "json",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "printf",
      "python",
      "query",
      "regex",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
    },
  },
  ---@param opts TSConfig
  config = function(_, opts)
    local TS = require("nvim-treesitter")

    setmetatable(require("nvim-treesitter.install"), {
      __newindex = function(_, k)
        if k == "compilers" then
          vim.schedule(function()
            Util.error({
              "Setting custom compilers for `nvim-treesitter` is no longer supported.",
              "",
              "For more info, see:",
              "- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)",
            })
          end)
        end
      end,
    })

    -- some quick sanity checks
    if not TS.get_installed then
      return Util.error("Please use `:Lazy` and update `nvim-treesitter`")
    elseif type(opts.ensure_installed) ~= "table" then
      return Util.error("`nvim-treesitter` opts.ensure_installed must be a table")
    end

    -- setup treesitter
    TS.setup(opts)
    Util.treesitter.get_installed(true) -- initialize the installed langs

    -- install missing parsers
    local install = vim.tbl_filter(function(lang)
      return not Util.treesitter.have(lang)
    end, opts.ensure_installed or {})
    if #install > 0 then
      Util.treesitter.build(function()
        TS.install(install, { summary = true }):await(function()
          Util.treesitter.get_installed(true) -- refresh the installed langs
        end)
      end)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
      callback = function(ev)
        local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
        if not Util.treesitter.have(ft) then
          return
        end

        ---@param feat string
        ---@param query string
        local function enabled(feat, query)
          local f = opts[feat] or {} ---@type TSFeat
          return f.enable ~= false
            and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
            and Util.treesitter.have(ft, query)
        end

        -- highlighting
        if enabled("highlight", "highlights") then
          pcall(vim.treesitter.start, ev.buf)
        end

        -- indents
        if enabled("indent", "indents") then
          Util.set_default("indentexpr", "v:lua.Util.treesitter.indentexpr()")
        end

        -- folds
        if enabled("folds", "folds") then
          if Util.set_default("foldmethod", "expr") then
            Util.set_default("foldexpr", "v:lua.Util.treesitter.foldexpr()")
          end
        end
      end,
    })
  end,
}
