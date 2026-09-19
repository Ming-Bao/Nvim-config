-- Completion engine (blink.cmp), with snippets from friendly-snippets and lua completion from lazydev.
---@diagnostic disable: missing-fields
return {
    "saghen/blink.cmp",
    version = "*", -- prebuilt binaries, use `build = "cargo build --release"` to follow main instead
    dependencies = { "rafamadriz/friendly-snippets" },
    event = { "InsertEnter", "CmdlineEnter" },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        snippets = {
            expand = function(snippet)
                Util.cmp.expand(snippet)
            end,
        },

        appearance = {
            -- sets the fallback highlight groups to nvim-cmp's highlight groups
            -- useful for when your theme doesn't support blink.cmp
            -- will be removed in a future release, assuming themes add support
            use_nvim_cmp_as_default = false,
            -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- adjusts spacing to ensure icons are aligned
            nerd_font_variant = "mono",
            kind_icons = Util.icons.kinds,
        },

        completion = {
            accept = {
                -- experimental auto-brackets support
                auto_brackets = {
                    enabled = true,
                },
            },
            menu = {
                draw = {
                    treesitter = { "lsp" },
                },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
            },
            ghost_text = {
                enabled = vim.g.ai_cmp,
            },
        },

        -- experimental signature help support
        -- signature = { enabled = true },

        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
            per_filetype = {
                lua = { inherit_defaults = true, "lazydev" },
            },
            providers = {
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    score_offset = 100, -- show at a higher priority than lsp
                },
            },
        },

        cmdline = {
            enabled = true,
            keymap = {
                preset = "cmdline",
                ["<Right>"] = false,
                ["<Left>"] = false,
            },
            completion = {
                list = { selection = { preselect = false } },
                menu = {
                    auto_show = function(ctx)
                        return vim.fn.getcmdtype() == ":"
                    end,
                },
                ghost_text = { enabled = true },
            },
        },

        keymap = {
            preset = "super-tab", -- <Tab> accepts the selected item, <Enter> just inserts a newline
            ["<C-y>"] = { "select_and_accept" },
            -- <Tab>: accept the completion if the menu is open, else jump to the next snippet placeholder
            ["<Tab>"] = { "select_and_accept", Util.cmp.map({ "snippet_forward" }), "fallback" },
        },
    },
}
