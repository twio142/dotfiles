_G.ya = ya
_G.ui = ui
_G.THEME = THEME
_G.Linemode = Linemode

require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

require("searchjump"):setup {
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
	search_patterns = {}  -- demo:{"%.e%d+","s%d+e%d+"}
}

THEME.git = THEME.git or {}
THEME.git.modified_sign = "M"
THEME.git.added_sign = "A"
THEME.git.untracked_sign = "?"
THEME.git.deleted_sign = "D"
THEME.git.ignored_sign = ""
require("git"):setup()

require("githead"):setup()

function Linemode:size_and_mtime()
	local year = os.date("%Y")
	local ts = math.floor((self._file.cha.modified or 0))
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
		return ui.Line {}
	end

	local linked = ""
	if h.link_to ~= nil then
		linked = " → " .. tostring(h.link_to)
	end
	return ui.Line(" " .. h.name .. linked)
end
