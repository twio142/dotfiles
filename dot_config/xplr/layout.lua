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

xplr.fn.custom.fmt_modified = function(m)
  return os.date("%Y-%m-%d %H:%M", m.last_modified / 1e9)
end

xplr.config.general.table.row.cols = {
  xplr.config.general.table.row.cols[2],
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

