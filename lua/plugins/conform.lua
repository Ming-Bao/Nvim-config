-- Formatting. Runs on save (toggle with <leader>uf), or manually with <leader>cf.
-- Formatters are picked per filetype in `formatters_by_ft`, and installed by mason (see mason.lua).
return {
    "stevearc/conform.nvim",
    dependencies = { "mason-org/mason.nvim" },
    lazy = true,
    cmd = "ConformInfo",
    keys = {
        {
            "<leader>cF",
            function()
                require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
            end,
            mode = { "n", "x" },
            desc = "Format Injected Langs",
        },
    },
    init = function()
        -- Register conform as the primary formatter for Util.format (the BufWritePre autocmd and <leader>cf)
        Util.on_very_lazy(function()
            Util.format.register({
                name = "conform.nvim",
                priority = 100,
                primary = true,
                format = function(buf)
                    require("conform").format({ bufnr = buf })
                end,
                sources = function(buf)
                    local ret = require("conform").list_formatters(buf)
                    ---@param v conform.FormatterInfo
                    return vim.tbl_map(function(v)
                        return v.name
                    end, ret)
                end,
            })
        end)
    end,
    ---@type conform.setupOpts
    opts = {
        default_format_opts = {
            timeout_ms = 3000,
            async = false, -- not recommended to change
            quiet = false, -- not recommended to change
            lsp_format = "fallback", -- not recommended to change
        },
        -- Don't set `format_on_save` here, Util.format handles that.
        formatters_by_ft = {
            lua = { "stylua" },
            fish = { "fish_indent" },
            sh = { "shfmt" },
        },
        -- The options you set here will be merged with the builtin formatters.
        -- You can also define any custom formatters here.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
            injected = { options = { ignore_errors = true } },
            -- # Example of using dprint only when a dprint.json file is present
            -- dprint = {
            --   condition = function(ctx)
            --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
            --   end,
            -- },
            --
            -- # Example of using shfmt with extra args
            -- shfmt = {
            --   prepend_args = { "-i", "2", "-ci" },
            -- },
        },
    },
}
