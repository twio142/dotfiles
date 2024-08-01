#!/bin/zsh

branch=$(git -C "$1" rev-parse --abbrev-ref HEAD) || return 1;
staged=$(git -C "$1" diff --staged --name-only | wc -l)
[ "$staged" -gt 0 ] && staged='+' || staged=''
dirty=$(git -C "$1" diff --name-only | wc -l)
[ "$dirty" -gt 0 ] && dirty='✷' || dirty=''
ahead=$(git -C "$1" rev-list --count HEAD ^$(git -C "$1" for-each-ref --format '%(upstream:short)' $(git -C "$1" symbolic-ref -q HEAD)) 2> /dev/null)
[ "$ahead" -gt 0 ] && ahead=" 󱦲$ahead" || ahead=''
echo -n "$branch$staged$dirty$ahead "
