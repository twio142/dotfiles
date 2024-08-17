#!/bin/zsh

branch=$(git -C "$1" rev-parse --abbrev-ref HEAD) || return 1;
[[ -n $2 && $2 -le 80 ]] && { echo -n "$branch "; return 0; }
staged=$(git -C "$1" diff --staged --name-only | wc -l)
[ "$staged" -gt 0 ] && staged=" +${staged// }" || staged=''
dirty=$(git -C "$1" diff --name-only | wc -l)
[ "$dirty" -gt 0 ] && dirty=" ✷${dirty// }" || dirty=''
new=$(git -C "$1" ls-files --others --exclude-standard | wc -l)
[ "$new" -gt 0 ] && new=" ?${new// }" || new=''
ahead=$(git -C "$1" rev-list --count HEAD ^$(git -C "$1" for-each-ref --format '%(upstream:short)' $(git -C "$1" symbolic-ref -q HEAD)) 2> /dev/null)
behind=$(git -C "$1" rev-list --count $(git -C "$1" for-each-ref --format '%(upstream:short)' $(git -C "$1" symbolic-ref -q HEAD)) ^HEAD 2> /dev/null)
[ "$ahead" -gt 0 ] && ahead="󱦲$ahead" || ahead=''
[ "$behind" -gt 0 ] && behind="󱦳$behind" || behind=''
[ -n "$ahead$behind" ] && separator=" " || separator=''
echo -n "$branch$staged$dirty$new$separator$ahead$behind "
