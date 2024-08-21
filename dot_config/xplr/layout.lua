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
    r = r .. m.meta.icon .. " "
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
      r = r .. symlink_path:gsub("\n", nl)
    end
  end

  return r
end

xplr.fn.custom.fmt_modified = function(m)
  return os.date("%Y-%m-%d %H:%M", m.last_modified / 1e9)
end

xplr.config.general.table.row.cols = {
  { format = "custom.fmt_path" },
  xplr.config.general.table.row.cols[4],
  xplr.config.general.table.row.cols[3],
  { format = "custom.fmt_modified" },
}

xplr.config.layouts.builtin.default = {
  Vertical = {
    config = {
      margin = 0,
      horizontal_margin = 0,
      vertical_margin = 0,
      constraints = {
        { Percentage = 7 },
        { Percentage = 50 },
        { Percentage = 36 },
        { Percentage = 7 },
      }
    },
    splits = {
      "SortAndFilter",
      "Table",
      "Selection",
      "InputAndLogs",
    }
  }
}

