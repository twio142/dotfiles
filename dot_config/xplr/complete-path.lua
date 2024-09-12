xplr.fn.builtin.try_complete_path = function(m)
  if not m.input_buffer or m.input_buffer == "" then
    return
  end

  local function matches_all(str, paths)
    for _, path in ipairs(paths) do
      if string.sub(path, 1, #str) ~= str then
        return false
      end
    end
    return true
  end

  local path = m.input_buffer
  if path == "/" then
    return
  elseif string.sub(path, 1, 1) == "~" then
    path = os.getenv("HOME") .. string.sub(path, 2)
  elseif string.match(path, "%$%S+$") then
    local var = string.sub(string.match(path, "%$%S+$"), 2)
    if os.getenv(var) then
      path = os.getenv(var)
    end
  end
  local explorer_config = {
    filters = {
      { filter = "IRelativePathDoesStartWith", input = xplr.util.basename(path) },
    },
  }
  local parent = xplr.util.dirname(path)
  if not parent or parent == "" then
    parent = "./"
  elseif parent ~= "/" then
    parent = parent .. "/"
  end

  local nodes = xplr.util.explore(parent, explorer_config)
  if #nodes == 0 then
    explorer_config.filters[1].filter = "IRelativePathDoesContain"
    nodes = xplr.util.explore(parent, explorer_config)
    if #nodes == 0 then
      return
    end
  end

  local found = {}
  for _, node in ipairs(nodes) do
    table.insert(found, parent .. node.relative_path)
  end
  local count = #found

  if count == 0 then
    return
  elseif count == 1 then
    if xplr.util.is_dir(found[1]) then
      found[1] = found[1] .. "/"
    end
    return {
      { SetInputBuffer = found[1] },
    }
  else
    local first = found[1]
    while #first > #path and matches_all(path, found) do
      path = string.sub(first, 1, #path + 1)
    end

    if matches_all(path, found) then
      if xplr.util.is_dir(path) then
        path = path .. "/"
      end
      return {
        { SetInputBuffer = path },
      }
    end

    return {
      { SetInputBuffer = path and string.sub(path, 1, #path - 1) or m.input_buffer },
    }
  end
end
