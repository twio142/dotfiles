xplr.fn.custom.fmt_perm = function(m)
  return xplr.fn.builtin.fmt_general_table_row_cols_2(m)
end
xplr.fn.custom.fmt_size = function(m)
  return m.human_size or ""
end
xplr.fn.custom.fmt_modified = function(m)
  return os.date("%Y-%m-%d %H:%M", m.last_modified / 1e9)
end

xplr.config.general.table.row.cols[3] = { format = "custom.fmt_size" }
xplr.config.general.table.row.cols[4] = { format = "custom.fmt_perm" }
xplr.config.general.table.row.cols[5] = { format = "custom.fmt_modified" }

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

