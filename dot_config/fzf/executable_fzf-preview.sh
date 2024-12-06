#!/usr/bin/env bash
#
# https://github.com/junegunn/fzf/blob/master/bin/fzf-preview.sh
#
# The purpose of this script is to demonstrate how to preview a file or an
# image in the preview window of fzf.

if [[ $# -ne 1 ]]; then
  >&2 echo "usage: $0 FILENAME"
  exit 1
fi

file=${1/#\~\//$HOME/}
type=$(file --dereference --mime -- "$file")

if [ -d "$1" ]; then
  tree -atrC -L 4 -I .DS_Store -I .git -I node_modules -I __pycache__ "$1"
  exit
elif [[ ! $type =~ image/ ]]; then
  if (command -v ouch > /dev/null) && (echo $type | grep -Eq "application\/(.*zip|x-tar|x-bzip2?|x-7z-compressed|x-rar|x-xz)" ); then
    ouch l -t -y "$1"
    exit
  elif [[ $type =~ =binary ]]; then
    file "$1" | sed "s/: /\n\n/"
    exit
  elif [[ $type =~ "application/json;" ]] && (command -v jq > /dev/null); then
    cat "$1" | jq -C
    exit
  fi

  if command -v batcat > /dev/null; then
    batname="batcat"
  elif command -v bat > /dev/null; then
    batname="bat"
  else
    cat "$1"
    exit
  fi

  ${batname} --style=plain --color=always --pager=never -- "$file"
  exit
fi

dim=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}
if [[ $dim = x ]]; then
  dim=$(stty size < /dev/tty | awk '{print $2 "x" $1}')
fi

# 1. Use chafa with Sixel output
if command -v chafa > /dev/null; then
  if [ -n "$FORMATTER" ]; then
    chafa -f $FORMATTER -s "$dim" -c full "$file"
  elif [ -n "$TMUX_POPUP" ]; then
    chafa -f symbols -s "$dim" -c full "$file"
  else
    if [[ -n "$TMUX" ]] && [[ "${dim#*x}" -gt 58 || ${dim%x*} -gt 58 ]]; then
      dim=58x58
    fi
    chafa -f sixel -s "$dim" -c full "$file"
  fi
  # Add a new line character so that fzf can display multiple images in the preview window
  echo

# 2. If chafa is not found but imgcat is available, use it on iTerm2
elif command -v imgcat > /dev/null; then
  # NOTE: We should use https://iterm2.com/utilities/it2check to check if the
  # user is running iTerm2. But for the sake of simplicity, we just assume
  # that's the case here.
  imgcat --width "${dim%%x*}" --height "${dim##*x}" "$file" 2> /dev/null

# 3. Cannot find any suitable method to preview the image
else
  file "$file" | sed "s/: /\n\n/"
fi
