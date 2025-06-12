#!/bin/zsh

# list Finder tags with fzf

tmpfile="/tmp/fzf-tag"
exec=$0
touch $tmpfile
tags=()
while IFS= read -r tag; do
  tags+=("$tag")
done < <(tag -u | awk '{print $2}')
[ ${#tags[@]} -eq 0 ] && exit

make_header() {
  declare -A colors
  colors=(
    ["red"]="31"
    ["orange"]="38;5;208"
    ["yellow"]="33"
    ["green"]="32"
    ["blue"]="34"
    ["purple"]="35"
    ["grey"]="90"
  )
  header=
  if [ -z $1 ]; then
    return 1
  fi
  for tag in $tags; do
    [ "$tag" = "$1" ] && icon="●" || icon="○"
    header+="\e[${colors[$tag]}m${icon}\e[0m  "
  done
  echo $header
}

cycle() {
  last_tag=$(cat $tmpfile)
  if [ -n "$last_tag" ]; then
    for i in {1..${#tags[@]}}; do
      if [ "${tags[$i]}" = "$last_tag" ]; then
        current_tag=${tags[$i+$1]}
        break
      fi
    done
  fi
  echo ${current_tag:-${tags[$1]}}
}

_fzf_tag() {
  [ -z $1 ] && exit
  fzf -m --preview 'fzf-preview {}' --preview-window=up,60% \
    --header "$(make_header $1)" \
    --bind "start:reload(tag -f $1 -A)" \
    --bind "ctrl-n:reload('$exec' --next)+transform-header:('$exec' --header-next)" \
    --bind "ctrl-p:reload('$exec' --prev)+transform-header:('$exec' --header-prev)"
}

case $1 in
  --header-*)
    [[ $1 =~ next ]] && tag=$(cycle 1) || tag=$(cycle -1)
    make_header $tag ;;
  --next|--prev)
    [[ $1 =~ next ]] && tag=$(cycle 1) || tag=$(cycle -1)
    echo $tag > $tmpfile
    tag -f $tag -A ;;
  *)
    tag=$(cycle 1)
    echo $tag > $tmpfile
    _fzf_tag $tag
    rm $tmpfile ;;
esac
