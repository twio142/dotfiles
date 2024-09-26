#!/bin/zsh

[ -z "$1" ] || exec man "$1" | col -bx | bat -l man -p
