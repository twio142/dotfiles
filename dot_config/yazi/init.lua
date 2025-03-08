---@diagnostic disable: undefined-global

require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

require("searchjump"):setup({
	unmatch_fg = "#b2a496",
	match_str_fg = "#000000",
	match_str_bg = "#73AC3A",
	first_match_str_fg = "#000000",
	first_match_str_bg = "#73AC3A",
	lable_fg = "#EADFC8",
	lable_bg = "#BA603D",
	only_current = false, -- only search the current window
	show_search_in_statusbar = false,
	auto_exit_when_unmatch = true,
	enable_capital_lable = false,
	search_patterns = {}, -- demo:{"%.e%d+","s%d+e%d+"}
})

require("mactag"):setup({
	-- Keys used to add or remove tags
	keys = {
		r = "red",
		o = "orange",
		y = "yellow",
		g = "green",
		b = "blue",
		p = "purple",
		x = "grey",
	},
	-- Colors used to display tags
	colors = {
		red = "#da6963",
		orange = "#f1a26f",
		yellow = "#fbff6a",
		green = "#91fc87",
		blue = "#43a1ff",
		purple = "#8764d2",
		grey = "#b2b2b2",
	},
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

require("session"):setup({
	sync_yanked = true,
})

require("my-cmd"):setup()

local width = io.popen("tput cols", "r"):read("*a")
if tonumber(width) and tonumber(width) < 95 then
	require("toggle-pane"):entry("min-preview")
	rt.mgr.ratio.preview = 0
end

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

-- -- Show ownership in status bar
-- Status:children_add(function()
-- 	local h = cx.active.current.hovered
-- 	if h == nil or ya.target_family() ~= "unix" then
-- 		return ""
-- 	end
-- 	return ui.Line({
-- 		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
-- 		":",
-- 		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
-- 		" ",
-- 	})
-- end, 500, Status.RIGHT)
