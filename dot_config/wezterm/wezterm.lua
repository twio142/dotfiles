--
-- ██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗
-- ██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
-- ██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
-- ██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
-- ╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
--  ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
-- A GPU-accelerated cross-platform terminal emulator
-- https://wezfurlong.org/wezterm/

local k = require("utils/keys")
local h = require("utils/helpers")
local wezterm = require("wezterm")
local act = wezterm.action
local opacity = 0.85
local config = {
  -- ╭─────────────────────────────────────────────────────────╮
  -- │                         GENERAL                         │
  -- ╰─────────────────────────────────────────────────────────╯
  check_for_updates = false,
  --
  -- SHELL
  default_prog = {"/bin/zsh", "-lc", "tmux"},
  set_environment_variables = {
    TERM = "wezterm",
    LANG = "en_US.UTF-8",
  },
  -- ╭─────────────────────────────────────────────────────────╮
  -- │                       APPEARANCE                        │
  -- ╰─────────────────────────────────────────────────────────╯
  -- FONT
  font_size = 12.0,
  -- font = wezterm.font_with_fallback({
  --   "FiraCode Nerd Font",
  --   "JetBrainsMono Nerd Font",
  --   "SF Pro",
  -- }),
  font_rules = {
    { intensity = "Normal", italic = true, font = wezterm.font_with_fallback({
      { family = "JetBrainsMono NF", weight = "Regular", italic = true },
      { family = "SF Pro", weight = "Regular", italic = true },
    }) },
    { intensity = "Bold", italic = true, font = wezterm.font_with_fallback({
      { family = "JetBrainsMono Nerd Font", weight = "ExtraBold", italic = true },
      { family = "SF Pro", weight = "Bold" , italic = true },
    }) },
    { intensity = "Normal", font = wezterm.font_with_fallback({
      { family = "FiraCode Nerd Font", weight = "Regular" },
      { family = "JetBrainsMono NF", weight = "Regular" },
      { family = "SF Pro", weight = "Regular" },
    }) },
    { intensity = "Bold", font = wezterm.font_with_fallback({
      { family = "FiraCode Nerd Font", weight = "Bold" },
      { family = "JetBrainsMono NF", weight = "ExtraBold" },
      { family = "SF Pro", weight = "Bold" },
    }) },
  },
  -- line_height = 1.0,
  -- underline_thickness = "200%",

  -- COLOR SCHEME
  color_scheme = h.is_dark() and "Tsusue Dark" or "Tsusue Light",
  -- color_scheme = h.is_dark() and "Catppuccin Mocha" or "Catppuccin Latte",

  -- WINDOW
  initial_cols = 120,
  initial_rows = 58,
  window_padding = {
    left = 3,
    right = 3,
    top = 3,
    bottom = 3,
  },
  adjust_window_size_when_changing_font_size = false,
  window_close_confirmation = "AlwaysPrompt",
  window_decorations = "RESIZE | MACOS_FORCE_ENABLE_SHADOW",
  window_background_opacity = opacity,
  macos_window_background_blur = 70,
  native_macos_fullscreen_mode = false,

  -- TABS
  enable_tab_bar = true,
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
  show_new_tab_button_in_tab_bar = false,
  -- colors = {
  --   tab_bar = {
  --     background = "rgba(12%, 12%, 18%, 90%)",
  --     active_tab = {
  --       bg_color = "#cba6f7",
  --       fg_color = "rgba(12%, 12%, 18%, 0%)",
  --       intensity = "Bold",
  --     },
  --     inactive_tab = {
  --       fg_color = "#cba6f7",
  --       bg_color = "rgba(12%, 12%, 18%, 90%)",
  --       intensity = "Normal",
  --     },
  --     inactive_tab_hover = {
  --       fg_color = "#cba6f7",
  --       bg_color = "rgba(27%, 28%, 35%, 90%)",
  --       intensity = "Bold",
  --     },
  --     new_tab = {
  --       fg_color = "#808080",
  --       bg_color = "#1e1e2e",
  --     },
  --   },
  -- },

  -- CURSOR
  default_cursor_style = "BlinkingBlock",
  cursor_blink_rate = 550,
  cursor_blink_ease_in = 'Constant',
  cursor_blink_ease_out = 'Constant',

  -- ╭─────────────────────────────────────────────────────────╮
  -- │                          KEYS                           │
  -- ╰─────────────────────────────────────────────────────────╯
  keys = {
    k.cmd_key("LeftArrow", act.SendKey({ mods = "CTRL", key = "a" })),
    k.cmd_key("RightArrow", act.SendKey({ mods = "CTRL", key = "e" })),
    k.cmd_key("Backspace", act.SendKey({ mods = "CTRL", key = "u" })),
    k.cmd_key("Delete", act.SendKey({ mods = "OPT", key = "k" })),
    k.opt_key("LeftArrow", act.SendKey({ mods = "OPT", key = "b" })),
    k.opt_key("RightArrow", act.SendKey({ mods = "OPT", key = "f" })),
    k.opt_key("Backspace", act.SendKey({ mods = "OPT|CTRL", key = "h" })),
    k.opt_key("Delete", act.SendKey({ mods = "OPT", key = "d" })),
    k.cmd_key("z", act.Multiple({
      act.SendKey({ mods = "CTRL", key = "x" }),
      act.SendKey({ key = "u" }),
    })),
    k.cmd_to_tmux_prefix("s", "["),
    k.cmd_to_tmux_prefix("p", "]"),
    {
      mods = "CTRL",
      key = "Tab",
      action = act.Multiple({
        act.SendKey({ mods = "CTRL", key = " " }),
        act.SendKey({ key = "n" }),
      }),
    },
    {
      mods = "CTRL|SHIFT",
      key = "Tab",
      action = act.Multiple({
        act.SendKey({ mods = "CTRL", key = " " }),
        act.SendKey({ key = "p" }),
      }),
    },
    k.cmd_to_tmux_prefix("p", "]"),
    -- k.cmd_ctrl_key("t", act.EmitEvent("toggle-opacity")),
    k.cmd_key("j", "QuickSelect"),
    k.cmd_shift_key("s", "ActivateCopyMode"),
    k.cmd_shift_key("p", "ActivateCommandPalette"),
    {
      mods = 'ALT',
      key = 'Enter',
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      mods = "SHIFT",
      key = " ",
      action = act.SendKey({ mods = "OPT", key = " " }),
    }
  },

  selection_word_boundary = " \t\n{}[]()\"'`.,;:",
  scrollback_lines = 10000,
  send_composed_key_when_left_alt_is_pressed = true,
  send_composed_key_when_right_alt_is_pressed = false,
}

return config
