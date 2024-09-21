#!/bin/zsh

[ -z "$1" ] && exit 1
exec man "$1" | col -bx | bat -l man -p
