lua <<EOF
local actions = require "telescope.actions"
local action_layout = require("telescope.actions.layout")
require("telescope").setup {
  defaults = {
    mappings = {
      n = {
        ["<M-p>"] = action_layout.toggle_preview,
        ["<C-_>"] = action_layout.cycle_layout_next,
        ["?"] = "which_key",
      },
      i = {
        ["<M-p>"] = action_layout.toggle_preview,
        ["<C-u>"] = false,
        ["<C-j>"] = actions.move_selection_next,
        ["<Tab>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<S-Tab>"] = actions.move_selection_previous,
        ["<Esc>"] = actions.close,
        ["<C-h>"] = "which_key",
        ["<C-_>"] = action_layout.cycle_layout_next,
      },
    },
    sorting_strategy = "ascending",
    layout_config = {
      width = 0.8,
      height = 0.9,
      prompt_position = "bottom",
      horizontal = {
        preview_width = 0.55,
        results_width = 0.45,
      },
      vertical = {
        preview_height = 0.55,
        results_height = 0.45,
      },
    }
  },
  pickers = {
    buffers = {
      mappings = {
        i = {
          ["<C-x>"] = actions.delete_buffer,
        },
        n = {
          ["x"] = actions.delete_buffer,
        },
      }
    }
  }
}
EOF
