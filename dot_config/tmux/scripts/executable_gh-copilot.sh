#!/bin/zsh

# Open GitHub Copilot suggestions in a tmux popup

ghcs() {
	FUNCNAME="$funcstack[1]"
	TARGET="shell"
	local GH_DEBUG="$GH_DEBUG"
	local GH_HOST="$GH_HOST"

	read -r -d '' __USAGE <<-EOF
	Wrapper around \`gh copilot suggest\` to suggest a command based on a natural language description of the desired output effort.
	Supports executing suggested commands if applicable.

	USAGE
	  $FUNCNAME [flags] <prompt>

	FLAGS
	  -h, --help            Display help usage
	  -t, --target target   Target for suggestion; must be shell, gh, git
	                        default: "$TARGET"

	EXAMPLES

	- Guided experience
	  $ $FUNCNAME

	- Git use cases
	  $ $FUNCNAME -t git "Undo the most recent local commits"
	  $ $FUNCNAME -t git "Clean up local branches"
	  $ $FUNCNAME -t git "Setup LFS for images"

	- Working with the GitHub CLI in the terminal
	  $ $FUNCNAME -t gh "Create pull request"
	  $ $FUNCNAME -t gh "List pull requests waiting for my review"
	  $ $FUNCNAME -t gh "Summarize work I have done in issues and pull requests for promotion"

	- General use cases
	  $ $FUNCNAME "Kill processes holding onto deleted files"
	  $ $FUNCNAME "Test whether there are SSL/TLS issues with github.com"
	  $ $FUNCNAME "Convert SVG to PNG and resize"
	  $ $FUNCNAME "Convert MOV to animated PNG"
EOF

	local OPT OPTARG OPTIND
	while getopts "dht:-:" OPT; do
		if [ "$OPT" = "-" ]; then     # long option: reformulate OPT and OPTARG
			OPT="${OPTARG%%=*}"       # extract long option name
			OPTARG="${OPTARG#"$OPT"}" # extract long option argument (may be empty)
			OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
		fi

		case "$OPT" in
			help | h)
				echo "$__USAGE"
				return 0
				;;

			target | t)
				TARGET="$OPTARG"
				;;
		esac
	done

	# shift so that $@, $1, etc. refer to the non-option arguments
	shift "$((OPTIND-1))"

	TMPFILE="$(mktemp -t gh-copilotXXXXXX)"
	trap 'rm -f "$TMPFILE"' EXIT
	if gh copilot suggest -t "$TARGET" "$@" -s "$TMPFILE"; then
		if [ -s "$TMPFILE" ]; then
			FIXED_CMD="$(cat $TMPFILE)"
			printf "$FIXED_CMD" | tmux load-buffer -b gh-copilot -
		fi
	else
		return 1
	fi
}

[ -z "$TMUX" ] && return 0

SCRIPT_PATH="${(%):-%x}"

if [[ "$1" == popup ]]; then
	local -a tmp=($(command tmux display-message -p "#{pane_top} #{cursor_y} #{pane_left} #{cursor_x} #{window_height} #{window_width} #{status} #{status-position}"))
	local cursor_y=$((tmp[1] + tmp[2])) cursor_x=$((tmp[3] + tmp[4])) window_height=$tmp[5] window_width=$tmp[6] window_top=0
	local popup_height popup_y popup_width popup_x popup_min_size=(60 15)

	if [[ $tmp[8] == 'top' ]]; then
		window_top=$tmp[7]
		cursor_y=$((cursor_y + window_top))
	fi

	if (( cursor_y * 2 > window_height )); then # show above the cursor
		popup_height=$(( popup_min_size[2] < cursor_y - window_top ? popup_min_size[2] : cursor_y - window_top ))
		popup_y=$cursor_y
	else # show below the cursor
		popup_height=$(( popup_min_size[2] < window_height - cursor_y + window_top - 1 ? popup_min_size[2] : window_height - cursor_y + window_top - 1 ))
		popup_y=$(( cursor_y + popup_height + 1 ))
	fi

	# calculate the popup width and x position
	popup_width=$(( popup_min_size[1] < window_width ? popup_min_size[1] : window_width ))
	popup_x=$(( cursor_x + popup_width > window_width ? window_width - popup_width : cursor_x ))

	shift 1
	tmux popup -E -w $popup_width -h $popup_height -x $popup_x -y $popup_y "$SCRIPT_PATH" "$@"
	tmux show-buffer -b gh-copilot \; delete-buffer -b gh-copilot 2> /dev/null
else
	ghcs "$@"
fi
