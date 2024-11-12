_G.xplr = xplr

xplr.config.general.focus_ui.prefix = "▶ "
xplr.config.general.focus_ui.suffix = ""
xplr.config.general.selection_ui.prefix = "  "
xplr.config.general.selection_ui.suffix = ""
xplr.config.general.focus_selection_ui.prefix = "▶ "
xplr.config.general.focus_selection_ui.suffix = ""

xplr.config.general.table.header.cols = {
  { format = "╭─ path" },
  { format = "size" },
  { format = "perm" },
  { format = "modified" },
}

xplr.config.general.table.col_widths = {
  { Percentage = 60 },
  { Percentage = 10 },
  { Percentage = 10 },
  { Percentage = 20 },
}

xplr.fn.custom.fmt_path = function(m)
  local nl = xplr.util.paint("\\n", { add_modifiers = { "Italic", "Dim" } })
  local r = m.tree .. m.prefix
  local ls_style = xplr.util.lscolor(m.absolute_path)
  local style = xplr.util.style_mix({ ls_style, m.style })

  if m.meta.icon == nil then
    r = r .. ""
  else
    r = r .. m.meta.icon
  end

  local rel = m.relative_path
  if m.is_dir then
    rel = rel .. "/"
  end
  r = r .. xplr.util.paint(rel, style)

  r = r .. m.suffix .. " "

  if m.is_symlink then
    r = r .. "→ "

    if m.is_broken then
      r = r .. "×"
    else
      local symlink_path =
        xplr.util.shorten(m.symlink.absolute_path, { base = m.parent })
      if m.symlink.is_dir then
        symlink_path = symlink_path .. "/"
      end
      local mods = m.is_focused and { "Italic" } or { "Italic", "Dim" }
      symlink_path = xplr.util.paint(symlink_path, { add_modifiers = mods })
      r = r .. symlink_path:gsub("\n", nl)
    end
  end

  return r
end

xplr.fn.custom.fmt_size = function(m)
  if m.is_dir then
    return ""
  elseif m.is_focused then
    return xplr.util.paint(m.human_size, { add_modifiers = { "Bold" } })
  else
    return m.human_size
  end
end

xplr.fn.custom.fmt_perm = function(m)
  local mods = {}
  if m.is_focused then
    table.insert(mods, "Bold")
  end
  local r = xplr.util.paint("r", { fg = "Green", add_modifiers = mods })
  local w = xplr.util.paint("w", { fg = "Yellow", add_modifiers = mods })
  local x = xplr.util.paint("x", { fg = "Red", add_modifiers = mods })
  local s = xplr.util.paint("s", { fg = "Red", add_modifiers = mods })
  local S = xplr.util.paint("S", { fg = "Red", add_modifiers = mods })
  local t = xplr.util.paint("t", { fg = "Red", add_modifiers = mods })
  local T = xplr.util.paint("T", { fg = "Red", add_modifiers = mods })
  local n = xplr.util.paint("-", { fg = "White", add_modifiers = mods })
  return xplr.util
    .permissions_rwx(m.permissions)
    :gsub("r", r)
    :gsub("w", w)
    :gsub("x", x)
    :gsub("s", s)
    :gsub("S", S)
    :gsub("t", t)
    :gsub("T", T)
    :gsub("-", n)
end

xplr.fn.custom.fmt_modified = function(m)
  local t = os.date("%Y-%m-%d %H:%M", m.last_modified / 1e9)
  if m.is_focused then
    return xplr.util.paint(t, { add_modifiers = { "Bold" } })
  else
    return t
  end
end

xplr.config.general.table.row.cols = {
  { format = "custom.fmt_path" },
  { format = "custom.fmt_size" },
  { format = "custom.fmt_perm" },
  { format = "custom.fmt_modified" },
}

xplr.config.layouts.builtin.default = {
  Vertical = {
    config = {
      margin = 0,
      horizontal_margin = 0,
      vertical_margin = 0,
      constraints = {
        { Max = 3 },
        { Percentage = 50 },
        { Min = 0 },
        { Max = 3 },
      }
    },
    splits = {
      "SortAndFilter",
      "Table",
      {
        Horizontal = {
          config = {
            margin = 0,
            horizontal_margin = 0,
            vertical_margin = 0,
            constraints = {
              { Min = 0 },
              { Max = 30 },
            }
          },
          splits = {
            "Selection",
            "HelpMenu",
          }
        }
      },
      "InputAndLogs",
    }
  }
}

