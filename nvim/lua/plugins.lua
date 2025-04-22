return { 
    -- Bufferline 
    {
        'akinsho/bufferline.nvim',
        dependencies = 'nvim-tree/nvim-web-devicons'
    },
    -- Colorscheme
    {
       "folke/tokyonight.nvim",
       lazy = false,
       priority = 1000,
       opts = {},
    },
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' }
    },
    {
        "phaazon/hop.nvim",
        lazy = true,
    },
    {
        'nvim-tree/nvim-tree.lua',
        lazy = true,
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
    },
    -- Added this plugin.
    {
        'akinsho/toggleterm.nvim',
        config = true
    },
    -- Which-key Extension
    {
       "folke/which-key.nvim",
       event = "VeryLazy",
       opts = {
       },
        keys = {
           {
              "<leader>?",
              function()
                 require("which-key").show({ global = false })
              end,
              desc = "Buffer Local Keymaps (which-key)",
           },
           {
              "<leader>q",
              "<cmd>wqall!<CR>",
              desc = "Quit Neovim after saving the file",
           },
           {
              "<leader>p",
              "<cmd>Lazy<CR>",
              desc = "Plugin Manager",
           },
           {
              "<leader>e",
              "<cmd>NvimTreeToggle<CR>",
              desc = "File Explorer",
           },
           {
              "<leader>t",
              "<cmd>ToggleTerm direction=float<CR>",
              desc = "Terminal",
           },
      },
    },
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/nvim-cmp'},
    {'hrsh7th/cmp-buffer'},
    {'hrsh7th/cmp-path'},
    {'hrsh7th/cmp-nvim-lsp'},
    lazy = true,
}
