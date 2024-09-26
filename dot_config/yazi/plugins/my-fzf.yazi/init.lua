_G.ya = _G.ya or {}
_G.cx = _G.cx or {}
_G.Command = _G.Command or {}

-- local function fail(s, ...) ya.notify { title = "fzf", content = s:format(...), timeout = 5, level = "error" } end

local M = {}

M.z = function(cwd)
  ya.hide()
  local output = Command("fzf")
    :args({"--bind", "start:reload:zoxide query ${query} -l | awk '{ if (!seen[tolower()]++) print }' | grep -Fxv '${PWD}' || true"})
    :args({"--bind", "change:reload:zoxide query {q} -l | awk '{ if (!seen[tolower()]++) print }' | grep -Fxv '${PWD}' || true"})
    :args({"--disabled", "--preview", "fzf-preview {}"})
    :cwd(cwd)
    :stdout(Command.PIPED)
    :output()
  local selected = output.stdout:gsub("\n", "")
  if selected ~= "" then
    ya.manager_emit("cd", { selected })
  end
end

M.fd = function(cwd)
  ya.hide()
  local output = Command("fzf")
    :args({"--preview", "fzf-preview {}", "--header", "⌥D dir / ⌥L symlink / ⌥S socket / ⌥F file / ⌥X executable"})
    :args({"--bind", "start:reload(fd --type f -H -L --exclude .DS_Store --exclude .git {q})"})
    :args({"--bind", "alt-d:reload(fd --type d -H -L --exclude .DS_Store --exclude .git {q})+change-header( Directories )"})
    :args({"--bind", "alt-l:reload(fd --type l -H -L --exclude .DS_Store --exclude .git {q})+change-header( Symlinks )"})
    :args({"--bind", "alt-s:reload(fd --type s -H -L --exclude .DS_Store --exclude .git {q})+change-header( Sockets )"})
    :args({"--bind", "alt-f:reload(fd --type f -H -L --exclude .DS_Store --exclude .git {q})+change-header( Files )"})
    :args({"--bind", "alt-x:reload(fd --type x -H -L --exclude .DS_Store --exclude .git {q})+change-header( Executables )"})
    :cwd(cwd)
    :stdout(Command.PIPED)
    :output()
  local selected = output.stdout:gsub("\n", "")
  if selected ~= "" then
    ya.manager_emit(selected:find("/$") and "cd" or "reveal", { selected })
  end
end

M.mru = function()
  ya.hide()
  local output = Command("cat")
    :args({os.getenv("XDG_CACHE_HOME") .. "/neomru/file"})
    :stdout(Command.PIPED)
    :output()
  local files = {}
  for line in output.stdout:gmatch("[^\n]+") do
    if #files < 30 and line:find("^/") then
      table.insert(files, line)
    end
  end
  if #files == 0 then
    return
  end
  local child = Command("fzf")
    :args({"--preview", "bat --color=always {}"})
    :stdin(Command.PIPED)
    :stdout(Command.PIPED)
    :spawn()
  child:write_all(table.concat(files, "\n"))
  child:flush()
  local selected = child:wait_with_output().stdout:gsub("\n", "")
  if selected ~= "" then
    ya.manager_emit("reveal", { selected })
  end
end

M.fif = function(cwd)
  ya.hide()
  local child = Command("fif")
    :args({"-o"})
    :cwd(cwd)
    :stdout(Command.PIPED)
    :spawn()
  local files = {}
  local ln
  while true do
    local line, event = child:read_line()
    if event ~= 0 then break end
    local file, l = line:match("^([^:]+):(%d+):")
    ln = l
    table.insert(files, file)
  end
  if #files == 0 then return end
  local cmd = "nvim "
  if #files == 1 then
    cmd = cmd .. '"' .. files[1] .. '" +' .. ln
  else
    for _, file in ipairs(files) do
      cmd = cmd .. '"' .. file .. '" '
    end
  end
  ya.manager_emit("shell", { cmd, confirm = true, block = true })
end

M.git = function(cwd)
  ya.hide()
  local child = Command("awk")
    :arg("/recentrepos:/ {found=1; next} found && /^[^[:space:]]/ {exit} found {print}")
    :arg(os.getenv("XDG_STATE_HOME") .. "/lazygit/state.yml")
    :stdout(Command.PIPED)
    :spawn()
  local repos = {}
  while true do
    local repo, event = child:read_line()
    if event ~= 0 then break end
    repo = repo:gsub("^ +- ", ""):gsub("\n", "")
    if repo ~= "" and repo ~= cwd then
      table.insert(repos, repo)
    end
  end
  child = Command("fzf")
    :args({"--preview", [[echo -e "\033[1m$(basename {})\033[0m\n"; git -c color.status=always -C {} status -bs]], "--preview-window=wrap"})
    :stdin(Command.PIPED)
    :stdout(Command.PIPED)
    :spawn()
  child:write_all(table.concat(repos, "\n"))
  child:flush()
  local selected = child:wait_with_output().stdout:gsub("\n", "")
  if selected ~= "" then
    ya.manager_emit("cd", { selected })
  end
end

local state = ya.sync(function() return tostring(cx.active.current.cwd) end)

return {
  entry = function(_, args)
    local cwd = state()
    M[args[1]](cwd)
  end
}
