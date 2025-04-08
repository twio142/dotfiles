---@diagnostic disable: undefined-global

require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

th.mgr.cwd = ui.Style():fg("blue"):bold()
th.git = th.git or {}
th.git.modified_sign = ""
th.git.added_sign = "󰐕"
th.git.untracked_sign = ""
th.git.deleted_sign = "✖"
th.git.ignored_sign = ""
require("git"):setup()

require("githead"):setup({
	branch_prefix = "",
	branch_borders = "",
	branch_symbol = "",
	branch_color = "bright green",
	commit_symbol = "@",
	commit_color = "bright green",
	behind_symbol = "󱦳",
	behind_color = "bright green",
	ahead_symbol = "󱦲",
	ahead_color = "bright green",
	stashes_symbol = "*",
	stashes_color = "bright green",
	state_symbol = "~",
	staged_symbol = "+",
	unstaged_symbol = "!",
	untracked_symbol = "?",
})

require("session"):setup({
	sync_yanked = true,
})

function Linemode:size_and_mtime()
	local year = os.date("%Y")
	local ts = math.floor(self._file.cha.mtime or 0)
	local time

	if ts > 0 and os.date("%Y", ts) == year then
		time = os.date("%b %d %H:%M", ts)
	else
		time = ts and os.date("%b %d %Y", ts) or ""
	end

	local size = self._file:size()
	return ui.Line(string.format(" %s %s", size and ya.readable_size(size) or "", time))
end

function Status:name()
	local h = self._tab.current.hovered
	if not h then
		return ui.Line({})
	end

	local linked = ""
	if h.link_to ~= nil then
		local home = os.getenv("HOME")
		linked = " → " .. tostring(h.link_to):gsub("^" .. home .. "/", "~/")
	end
	return ui.Line(" " .. h.name .. linked)
end

-- Show ownership in status bar
Status:children_add(function()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ""
	end
	return ui.Line({
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	})
end, 500, Status.RIGHT)
