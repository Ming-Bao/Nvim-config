-- LSP setup. To add or remove a language server, add or remove a line in `servers` below.
-- Names come from nvim-lspconfig (see `:help lspconfig-all`); servers that mason knows about are
-- installed automatically, and every server listed here is enabled.
--   servers = { pyright = {} }            -- enable with the defaults
--   servers = { pyright = { mason = false } }   -- enable, but don't install with mason (use your system one)
--   servers = { pyright = { enabled = false } } -- keep the config around, but turn it off

-- symbol kinds shown in the symbol pickers (<leader>ss / <leader>sS), per filetype
local kind_filter = {
    default = {
        "Class",
        "Constructor",
        "Enum",
        "Field",
        "Function",
        "Interface",
        "Method",
        "Module",
        "Namespace",
        "Package",
        "Property",
        "Struct",
        "Trait",
    },
    markdown = false,
    help = false,
    -- you can specify a different filter for each filetype
    lua = {
        "Class",
        "Constructor",
        "Enum",
        "Field",
        "Function",
        "Interface",
        "Method",
        "Module",
        "Namespace",
        -- "Package", -- remove package since luals uses it for control flow structures
        "Property",
        "Struct",
        "Trait",
    },
}

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "mason-org/mason.nvim",
        { "mason-org/mason-lspconfig.nvim", config = function() end },
    },
    opts = function()
        ---@class PluginLspOpts
        local ret = {
            -- options for vim.diagnostic.config()
            ---@type vim.diagnostic.Opts
            diagnostics = {
                underline = true,
                update_in_insert = false,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●",
                    -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
                    -- prefix = "icons",
                },
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = Util.icons.diagnostics.Error,
                        [vim.diagnostic.severity.WARN] = Util.icons.diagnostics.Warn,
                        [vim.diagnostic.severity.HINT] = Util.icons.diagnostics.Hint,
                        [vim.diagnostic.severity.INFO] = Util.icons.diagnostics.Info,
                    },
                },
            },
            -- Enable this to enable the builtin LSP inlay hints on Neovim.
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the inlay hints.
            inlay_hints = {
                enabled = true,
                exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
            },
            -- Enable this to enable the builtin LSP code lenses on Neovim.
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the code lenses.
            codelens = {
                enabled = false,
            },
            -- Enable this to enable the builtin LSP folding on Neovim.
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the folds.
            folds = {
                enabled = true,
            },
            -- options for vim.lsp.buf.format
            -- `bufnr` and `filter` is handled by the Util.format formatter,
            -- but can be also overridden when specified
            format = {
                formatting_options = nil,
                timeout_ms = nil,
            },
            -- LSP Server Settings
            -- Sets the default configuration for an LSP client (or all clients if the special name "*" is used).
            ---@alias util.lsp.Config vim.lsp.Config|{mason?:boolean, enabled?:boolean, keys?:LazyKeysLspSpec[]}
            ---@type table<string, util.lsp.Config|boolean>
            servers = {
                -- configuration for all lsp servers
                ["*"] = {
                    capabilities = {
                        workspace = {
                            fileOperations = {
                                didRename = true,
                                willRename = true,
                            },
                        },
                    },
          -- stylua: ignore
          keys = {
            { "<leader>cl", function() Snacks.picker.lsp_config() end, desc = "Lsp Info" },
            { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", has = "definition" },
            { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
            { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
            { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
            { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
            { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
            { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
            { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
            { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" }, has = "codeAction" },
            { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" }, has = "codeLens" },
            { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
            { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
            { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
            { "<leader>cA", Util.lsp.action.source, desc = "Source Action", has = "codeAction" },
            { "<leader>ss", function() Snacks.picker.lsp_symbols({ filter = kind_filter }) end, desc = "LSP Symbols", has = "documentSymbol" },
            { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols({ filter = kind_filter }) end, desc = "LSP Workspace Symbols", has = "workspace/symbols" },
            { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming", has = "callHierarchy/incomingCalls" },
            { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing", has = "callHierarchy/outgoingCalls" },
            { "]]", function() Snacks.words.jump(vim.v.count1) end, has = "documentHighlight",
              desc = "Next Reference", enabled = function() return Snacks.words.is_enabled() end },
            { "[[", function() Snacks.words.jump(-vim.v.count1) end, has = "documentHighlight",
              desc = "Prev Reference", enabled = function() return Snacks.words.is_enabled() end },
            { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, has = "documentHighlight",
              desc = "Next Reference", enabled = function() return Snacks.words.is_enabled() end },
            { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, has = "documentHighlight",
              desc = "Prev Reference", enabled = function() return Snacks.words.is_enabled() end },
            {
              "<leader>co",
              Util.lsp.action["source.organizeImports"],
              desc = "Organize Imports",
              has = "codeAction",
              enabled = function(buf)
                local code_actions = vim.tbl_filter(function(action)
                  return action:find("^source%.organizeImports%.?$")
                end, Util.lsp.code_actions({ bufnr = buf }))
                return #code_actions > 0
              end
            },
          },
                },

                -- the servers ------------------------------------------------------
                -- add or remove servers here
                stylua = { enabled = false },
                lua_ls = {
                    -- mason = false, -- set to false if you don't want this server to be installed with mason
                    -- Use this to add any additional keymaps
                    -- for specific lsp servers
                    -- ---@type LazyKeysSpec[]
                    -- keys = {},
                    settings = {
                        Lua = {
                            workspace = {
                                checkThirdParty = false,
                            },
                            codeLens = {
                                enable = true,
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                            doc = {
                                privateName = { "^_" },
                            },
                            hint = {
                                enable = true,
                                setType = false,
                                paramType = true,
                                paramName = "Disable",
                                semicolon = "Disable",
                                arrayIndex = "Disable",
                            },
                        },
                    },
                },
                ts_ls = {},
                pyright = {},
            },
            -- you can do any additional lsp server setup here
            -- return true if you don't want this server to be setup with lspconfig
            ---@type table<string, fun(server:string, opts: vim.lsp.Config):boolean?>
            setup = {
                -- example to setup with typescript.nvim
                -- tsserver = function(_, opts)
                --   require("typescript").setup({ server = opts })
                --   return true
                -- end,
                -- Specify * to use this function as a fallback for any server
                -- ["*"] = function(server, opts) end,
            },
        }
        return ret
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
        -- setup autoformat
        Util.format.register(Util.lsp.formatter())

        -- setup keymaps
        local names = vim.tbl_keys(opts.servers) ---@type string[]
        table.sort(names)
        for _, server in ipairs(names) do
            local server_opts = opts.servers[server]
            if type(server_opts) == "table" and server_opts.keys then
                Util.lsp.set_keys({ name = server ~= "*" and server or nil }, server_opts.keys)
            end
        end

        -- inlay hints
        if opts.inlay_hints.enabled then
            Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buffer)
                if
                    vim.api.nvim_buf_is_valid(buffer)
                    and vim.bo[buffer].buftype == ""
                    and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
                then
                    vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
                end
            end)
        end

        -- folds
        if opts.folds.enabled then
            Snacks.util.lsp.on({ method = "textDocument/foldingRange" }, function()
                if Util.set_default("foldmethod", "expr") then
                    Util.set_default("foldexpr", "v:lua.vim.lsp.foldexpr()")
                end
            end)
        end

        -- code lens
        if opts.codelens.enabled and vim.lsp.codelens then
            Snacks.util.lsp.on({ method = "textDocument/codeLens" }, function(buffer)
                vim.lsp.codelens.refresh()
                vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                    buffer = buffer,
                    callback = vim.lsp.codelens.refresh,
                })
            end)
        end

        -- diagnostics
        if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
            opts.diagnostics.virtual_text.prefix = function(diagnostic)
                local icons = Util.icons.diagnostics
                for d, icon in pairs(icons) do
                    if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                        return icon
                    end
                end
                return "●"
            end
        end
        vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

        if opts.servers["*"] then
            vim.lsp.config("*", opts.servers["*"])
        end

        -- get all the servers that are available through mason-lspconfig
        local have_mason = Util.has("mason-lspconfig.nvim")
        local mason_all = have_mason
                and vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package)
            or {} --[[ @as string[] ]]
        local mason_exclude = {} ---@type string[]

        ---@return boolean? exclude automatic setup
        local function configure(server)
            if server == "*" then
                return false
            end
            local sopts = opts.servers[server]
            sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts --[[@as util.lsp.Config]]

            if sopts.enabled == false then
                mason_exclude[#mason_exclude + 1] = server
                return
            end

            local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)
            local setup = opts.setup[server] or opts.setup["*"]
            if setup and setup(server, sopts) then
                mason_exclude[#mason_exclude + 1] = server
            else
                vim.lsp.config(server, sopts) -- configure the server
                if not use_mason then
                    vim.lsp.enable(server)
                end
            end
            return use_mason
        end

        local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
        if have_mason then
            require("mason-lspconfig").setup({
                ensure_installed = install,
                -- Only enable the servers listed above. (LazyVim uses `{ exclude = mason_exclude }` here,
                -- which also enables anything you happen to have installed through :Mason.)
                automatic_enable = install,
            })
        end
    end,
}
