---@diagnostic disable: undefined-global

require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

THEME.git = THEME.git or {}
THEME.git.modified_sign = ""
THEME.git.added_sign = "󰐕"
THEME.git.untracked_sign = ""
THEME.git.deleted_sign = "✖"
THEME.git.ignored_sign = ""
require("git"):setup()

require("githead"):setup({
	branch_prefix = "",
	branch_borders = "",
	branch_symbol = "",
	commit_symbol = "@",
	behind_symbol = "󱦳",
	ahead_symbol = "󱦲",
	stashes_symbol = "*",
	state_symbol = "~",
	staged_symbol = "+",
	unstaged_symbol = "!",
	untracked_symbol = "?",
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
