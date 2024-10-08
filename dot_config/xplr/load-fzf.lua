_G.xplr = xplr

local _hd = function(t)
  local types = {
    f = "file",
    d = "dir",
    l = "symlink",
    s = "socket",
    x = "executable",
  }
  local header = {}
  local BOLD="\x1b[1;36m"
  local OFF="\x1b[0m"
  for k, v in pairs(types) do
    local h = t == k and BOLD or ""
    h = h .. string.format("⌥%s %s", string.upper(k), v)
    h = h .. (t == k and OFF or "")
    table.insert(header, h)
  end
  return table.concat(header, " / ")
end

local _fd = function(k, t)
  return string.format("%s:reload(fd --type %s -H -L --exclude .DS_Store --exclude .git --strip-cwd-prefix=always .)+change-header( %s )", k, t, _hd(t))
end

require("fzf").setup{
  args = string.format('-m --preview "fzf-preview {}" --bind "%s" --bind "%s" --bind "%s" --bind "%s" --bind "%s" --bind "%s"',
    _fd("start", "f"),
    _fd("alt-d", "d"),
    _fd("alt-l", "l"),
    _fd("alt-s", "s"),
    _fd("alt-f", "f"),
    _fd("alt-x", "x")
  ),
  recursive = true,
  enter_dir = true,
}

xplr.config.modes.custom.backslash.key_bindings.on_key.f = {
  help = "fzf",
  messages = {
    "PopMode",
    { CallLua = "custom.fzf.search" },
  },
}

require("fzf").setup{
  name = "autojump",
  args = [[ --bind "start:reload:zoxide query '' -l --exclude '${PWD}' | awk '{ if (!seen[tolower()]++) print }' || true" \
    --bind "change:reload:zoxide query {q} -l --exclude '${PWD}' | awk '{ if (!seen[tolower()]++) print }' || true" \
    --disabled --preview "fzf-preview {}" | xargs -I _ rp "_" ]],
  recursive = true,
  enter_dir = true,
  mode = "custom.backslash",
  key = "g"
}

require("fzf").setup{
  name = "fif",
  bin = "fif",
  args = "-o",
  recursive = true,
  mode = "custom.backslash",
  key = "s",
  callback = "custom.fif_callback"
}

require("fzf").setup{
  name = "obsidian search",
  bin = "obsearch",
  args = "-o",
  recursive = true,
  mode = "custom.backslash",
  key = "o",
  callback = "custom.fif_callback"
}

xplr.fn.custom.fif_callback = function(input)
  -- if multiple lines are selected, open them all in nvim
  -- if a single line is selected, open the file at the line number in nvim
  local cmd = "nvim "
  if #input > 1 then
    for _, i in ipairs(input) do
      local path = i:match("^[^:]+")
      cmd = cmd .. xplr.util.shell_escape(path) .. " "
    end
  elseif #input == 1 then
    local path = xplr.util.shell_escape(input[1]:match("^[^:]+"))
    local line = input[1]:match(":(%d+)$")
    line = line and " +" .. line or ""
    cmd = cmd .. path .. line
  else
    return
  end
  return {
    { BashExec = cmd },
    "PopMode",
  }
end

require("fzf").setup{
  name = "recent files",
  bin = "cat",
  args = os.getenv("XDG_CACHE_HOME") .. "/neomru/file | grep -E '^/' | fzf -m --tail 30 --preview 'bat --color=always {}'",
  recursive = true,
  mode = "custom.backslash",
  key = "r",
}

require("fzf").setup{
  name = "recent repos",
  bin = "awk",
  args = "'/recentrepos:/ {found=1; next} found && /^[^[:space:]]/ {exit} found {print}'" .. [[ $XDG_STATE_HOME/lazygit/state.yml | sd '^ +- ' '' | grep -Fxv '$PWD' | fzf --preview 'echo -e "\033[1m$(basename {})\033[0m\n"; git -c color.status=always -C {} status -bs' --preview-window=wrap]] ,
  recursive = true,
  enter_dir = true,
  mode = "custom.backslash",
  key = "R",
}

xplr.fn.custom.edit_files = function(input)
  local cmd = "nvim "
  if #input > 0 and type(input[1]) == "string" then
    for _, file in ipairs(input) do
      cmd = cmd .. xplr.util.shell_escape(file) .. " "
    end
  elseif input.selection and #input.selection > 0 then
    for _, node in ipairs(input.selection) do
      cmd = cmd .. xplr.util.shell_escape(node.absolute_path) .. " "
    end
  end
  return { { BashExec0 = cmd } }
end

xplr.config.modes.builtin.selection_ops.key_bindings.on_key['ctrl-e'] = {
  help = "edit selection",
  messages = xplr.config.modes.builtin.selection_ops.key_bindings.on_key.e.messages,
}
xplr.config.modes.builtin.selection_ops.key_bindings.on_key.e = {
  help = "[e]dit selected files",
  messages = {
    "PopMode",
    { CallLua = "custom.edit_files" },
  },
}
