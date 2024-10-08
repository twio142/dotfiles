#!/bin/zsh
__fzf_git_color() {
  if [[ -n $NO_COLOR ]]; then
    echo never
  elif [[ $# -gt 0 ]] && [[ -n $FZF_GIT_PREVIEW_COLOR ]]; then
    echo "$FZF_GIT_PREVIEW_COLOR"
  else
    echo "${FZF_GIT_COLOR:-always}"
  fi
}

__fzf_git_cat() {
  if [[ -n $FZF_GIT_CAT ]]; then
    echo "$FZF_GIT_CAT"
    return
  fi

  # Sometimes bat is installed as batcat
  _fzf_git_bat_options="--style='${BAT_STYLE:-full}' --color=$(__fzf_git_color .) --pager=never --tabs 2"
  if command -v batcat > /dev/null; then
    echo "batcat $_fzf_git_bat_options"
  elif command -v bat > /dev/null; then
    echo "bat $_fzf_git_bat_options"
  else
    echo cat
  fi
}

__fzf_git_pager() {
  local pager
  pager="${FZF_GIT_PAGER:-${GIT_PAGER:-$(git config --get core.pager 2>/dev/null)}}"
  echo "${pager:-cat} | expand -t 2"
}

_fzf_git_fzf() {
  fzf-tmux -p95%,70% -- \
    --multi --height=50% --min-height=20 --border \
    --border-label-pos=2 \
    --color='header:underline,label:bold' \
    --preview-window='right,60%,border-left' \
    --bind='ctrl-d:preview-half-page-down' --bind='ctrl-u:preview-half-page-up' --bind='alt-j:jump' \
    --bind="ctrl-\\:change-preview-window(down,65%,border-top|hidden|)" "$@"
}

_fzf_git_check() {
  git rev-parse HEAD > /dev/null 2>&1 && return

  [[ -n $TMUX ]] && tmux display-message "Not in a git repository"
  exit 0
}

__fzf_git=${BASH_SOURCE[0]:-${(%):-%x}}
__fzf_git=$(readlink -f "$__fzf_git" 2> /dev/null || /usr/bin/ruby --disable-gems -e 'puts File.expand_path(ARGV.first)' "$__fzf_git" 2> /dev/null)

_fzf_git_files() {
  _fzf_git_check || return
  local root query
  root=$(git rev-parse --show-toplevel)
  [[ $root != "$PWD" ]] && query='!../ '

  git -c color.status=$(__fzf_git_color) status --short --no-branch |
  _fzf_git_fzf -m --ansi --nth 2..,.. \
    --border-label '  Files ' \
    --header $'⌃E edit ╱ ⌃A add all\n\n' \
    --bind "ctrl-a:reload(git add -A; git -c color.status=$(__fzf_git_color) status --short --no-branch)" \
    --bind "ctrl-e:execute:${EDITOR:-nvim} {+-1} > /dev/tty" \
    --bind "alt-o:execute-silent:bash $__fzf_git file {-1}" \
    --bind "ctrl-r:reload(git -c color.status=$(__fzf_git_color) status --short --no-branch)" \
    --bind "ctrl-x:execute:~/.config/fzf/fzf-git-input.sh {+-1}" \
    --bind "ctrl-y:execute-silent:echo -n {+-1} | tmux load-buffer -" \
    --query "$query" \
    --preview "git diff --no-ext-diff --color=$(__fzf_git_color .) -- {-1} | $(__fzf_git_pager); $(__fzf_git_cat) {-1}" "$@" |
  cut -c4- | sed 's/.* -> //'
}

open_in_nvim() {
  SESS="$(tmux display -p '#S')" $XDG_CONFIG_HOME/tmux/scripts/open_in_vim.sh "$@"
}

_fzf_git_branches() {
  _fzf_git_check || return
  bash "$__fzf_git" branches |
  _fzf_git_fzf --ansi \
    --border-label '  Branches ' \
    --header-lines 3 \
    --tiebreak begin \
    --preview-window down,border-top,70% \
    --no-hscroll \
    --bind "ctrl-f:change-border-label(  All branches )+reload:bash \"$__fzf_git\" all-branches" \
    --bind "alt-o:execute-silent:bash $__fzf_git branch {}" \
    --bind "ctrl-\\:change-preview-window(down,70%|hidden|)" \
    --bind "alt-d:execute:echo {} | sed 's/^..//' | cut -d' ' -f1 | xargs git diff --color=$(__fzf_git_color) > /dev/tty | bat --style=plain --tabs 2" \
    --bind "ctrl-o:reload(git checkout \$(echo {} | sed 's/^..//' | cut -d' ' -f1); bash \"$__fzf_git\" branches)" \
    --bind "ctrl-r:reload(bash \"$__fzf_git\" branches)+change-border-label(  Branches )" \
    --bind "ctrl-x:execute:~/.config/fzf/fzf-git-input.sh \$(echo {} | sed 's/^..//' | cut -d' ' -f1)" \
    --bind "ctrl-y:execute-silent:tmux set-buffer \$(echo {} | sed 's/^..//' | cut -d' ' -f1)" \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' \$(sed s/^..// <<< {} | cut -d' ' -f1) --" "$@" |
  sed 's/^..//' | cut -d' ' -f1
}

_fzf_git_tags() {
  _fzf_git_check || return
  git tag --sort -version:refname |
  _fzf_git_fzf --preview-window right,70% \
    --border-label '  Tags ' \
    --header $'⌥D diff ╱ ⌃O checkout tag\n\n' \
    --bind "alt-o:execute-silent:bash $__fzf_git tag {}" \
    --bind "alt-d:execute:git diff --color=$(__fzf_git_color) {} | bat --style=plain --tabs 2" \
    --bind "ctrl-o:reload(git checkout {}; git tag --sort -version:refname)" \
    --bind "ctrl-r:reload(git tag --sort -version:refname)" \
    --bind "ctrl-x:execute:~/.config/fzf/fzf-git-input.sh {+}" \
    --bind "ctrl-y:execute-silent:echo -n {+} | tmux load-buffer -" \
    --preview "git show --color=$(__fzf_git_color .) {} | $(__fzf_git_pager)" "$@"
}

_fzf_git_hashes() {
  _fzf_git_check || return
  bash "$__fzf_git" hashes |
  _fzf_git_fzf --ansi --no-sort --bind 'ctrl-s:toggle-sort' \
    --border-label '  Hashes ' \
    --header-lines 3 \
    --bind "ctrl-f:change-border-label(  All hashes )+reload:bash \"$__fzf_git\" all-hashes" \
    --bind "alt-o:execute-silent:bash $__fzf_git commit {}" \
    --bind "alt-d:execute:grep -o '[a-f0-9]\{7,\}' <<< {} | head -n 1 | xargs git diff --color=$(__fzf_git_color) > /dev/tty | bat --style=plain --tabs 2" \
    --bind "ctrl-o:reload(git checkout \$(echo -n {} | grep -Eo '[a-f0-9]{7,}.+' | cut -d' ' -f1); bash \"$__fzf_git\" hashes)" \
    --bind "ctrl-r:reload(bash \"$__fzf_git\" hashes)+change-border-label(  Hashes )" \
    --bind "ctrl-x:execute:mode=hash ~/.config/fzf/fzf-git-input.sh {+}" \
    --bind "ctrl-y:execute-silent:echo -n {+} | grep -Eo '[a-f0-9]{7,}.+' | cut -d' ' -f1 | tmux load-buffer -" \
    --preview "grep -o '[a-f0-9]\{7,\}' <<< {} | head -n 1 | xargs git show --color=$(__fzf_git_color .) | $(__fzf_git_pager)" "$@" |
  awk 'match($0, /[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]*/) { print substr($0, RSTART, RLENGTH) }'
}

_fzf_git_remotes() {
  _fzf_git_check || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  _fzf_git_fzf --tac \
    --border-label '  Remotes ' \
    --header $'⌃F fetch ╱ ⌥P push\n\n' \
    --bind "alt-o:execute-silent:bash $__fzf_git remote {1}" \
    --bind "alt-p:reload(git push {1} HEAD; git remote -v | awk '{print \$1 \"\t\" \$2}' | uniq)" \
    --bind "ctrl-f:reload(git fetch {1}; git remote -v | awk '{print \$1 \"\t\" \$2}' | uniq)" \
    --bind "ctrl-r:reload(git remote -v | awk '{print \$1 \"\t\" \$2}' | uniq)" \
    --bind "ctrl-x:execute:~/.config/fzf/fzf-git-input.sh {+1}" \
    --bind "ctrl-y:execute-silent:echo -n {+1} | tmux load-buffer -" \
    --preview-window right,70% \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' '{1}/$(git rev-parse --abbrev-ref HEAD)' --" "$@" |
  cut -d$'\t' -f1
}

_fzf_git_stashes() {
  _fzf_git_check || return
  git stash list | _fzf_git_fzf \
    --border-label ' 󰪶 Stashes ' \
    --header $'⌥A apply stash ╱ ⌥D drop stash\n\n' \
    --bind "alt-a:reload(git stash apply -q {1}; git stash list)" \
    --bind "alt-d:reload(git stash drop -q {1}; git stash list)" \
    --bind "ctrl-r:reload(git stash list)" \
    --bind "ctrl-x:execute:mode=stash ~/.config/fzf/fzf-git-input.sh {+1}" \
    --bind "ctrl-y:execute-silent:tmux set-buffer \$(echo {1} | cut -d: -f1)" \
    -d: --preview "git show --color=$(__fzf_git_color .) {1} | $(__fzf_git_pager)" "$@" |
  cut -d: -f1
}

_fzf_git_lreflogs() {
  _fzf_git_check || return
  git reflog --color=$(__fzf_git_color) --format="%C(blue)%gD %C(yellow)%h%C(auto)%d %gs" | _fzf_git_fzf --ansi \
    --border-label '  Reflogs ' \
    --bind "alt-d:execute:git diff --color=$(__fzf_git_color) {1} | bat --style=plain --tabs 2" \
    --bind "ctrl-o:reload(git checkout {1}; git reflog --color=$(__fzf_git_color) --format=\"%C(blue)%gD %C(yellow)%h%C(auto)%d %gs\")" \
    --bind "ctrl-r:reload(git reflog --color=$(__fzf_git_color) --format='%C(blue)%gD %C(yellow)%h%C(auto)%d %gs')" \
    --bind "ctrl-x:execute:~/.config/fzf/fzf-git-input.sh {+1}" \
    --bind "ctrl-y:execute-silent:echo -n {+1} | tmux load-buffer -" \
    --preview "git show --color=$(__fzf_git_color .) {1} | $(__fzf_git_pager)" "$@" |
  awk '{print $1}'
}

_fzf_git_each_ref() {
  _fzf_git_check || return
  bash "$__fzf_git" refs | _fzf_git_fzf --ansi \
    --nth 2,2.. \
    --tiebreak begin \
    --border-label '  Each ref ' \
    --header-lines 3 \
    --preview-window down,border-top,70% \
    --no-hscroll \
    --bind "ctrl-f:change-border-label(  Every ref )+reload:bash \"$__fzf_git\" all-refs" \
    --bind "alt-o:execute-silent:bash $__fzf_git {1} {2}" \
    --bind "ctrl-\\:change-preview-window(down,70%|hidden|)" \
    --bind "ctrl-o:reload(git checkout {2}; bash \"$__fzf_git\" refs)" \
    --bind "ctrl-r:reload(bash \"$__fzf_git\" refs)+change-border-label(  Each ref )" \
    --bind "ctrl-x:execute:~/.config/fzf/fzf-git-input.sh {+2}" \
    --bind "ctrl-y:execute-silent:echo -n {+2} | tmux load-buffer -" \
    --preview "git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' {2} --" "$@" |
  awk '{print $2}'
}

_fzf_git_worktrees() {
  _fzf_git_check || return
  git worktree list | _fzf_git_fzf \
    --border-label ' 󰙅 Worktrees ' \
    --header $'⌥D remove worktree\n\n' \
    --bind "alt-d:reload(git worktree remove {1} > /dev/null; git worktree list)" \
    --bind "ctrl-r:reload(git worktree list)" \
    --bind "ctrl-x:execute:~/.config/fzf/fzf-git-input.sh {+1}" \
    --preview "
      git -c color.status=$(__fzf_git_color .) -C {1} status --short --branch
      echo
      git log --oneline --graph --date=short --color=$(__fzf_git_color .) --pretty='format:%C(auto)%cd %h%d %s' {2} --
    " "$@" |
  awk '{print $1}'
}

if [[ $# -eq 1 ]]; then
  branches() {
    git branch "$@" --sort=-committerdate --sort=-HEAD --format=$'%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))\t%(color:blue)%(subject)%(color:reset)' --color=$(__fzf_git_color) | column -ts$'\t'
  }
  refs() {
    git for-each-ref --sort=-creatordate --sort=-HEAD --color=$(__fzf_git_color) --format=$'%(refname) %(color:green)(%(creatordate:relative))\t%(color:blue)%(subject)%(color:reset)' |
      eval "$1" |
      sed 's#^refs/remotes/#\x1b[95mremote-branch\t\x1b[33m#; s#^refs/heads/#\x1b[92mbranch\t\x1b[33m#; s#^refs/tags/#\x1b[96mtag\t\x1b[33m#; s#refs/stash#\x1b[91mstash\t\x1b[33mrefs/stash#' |
      column -ts$'\t'
  }
  hashes() {
    git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=$(__fzf_git_color) "$@"
  }
  case "$1" in
    branches)
      echo $'⌥D diff ╱ ⌃O checkout branch\n⌃F show all branches\n'
      branches
      ;;
    all-branches)
      echo $'⌥D diff ╱ ⌃O checkout branch\n\n'
      branches -a
      ;;
    hashes)
      echo $'⌥D diff ╱ ⌃S toggle sort\n⌃O checkout commit ╱ ⌃F show all hashes\n'
      hashes
      ;;
    all-hashes)
      echo $'⌥D diff ╱ ⌃S toggle sort\n⌃O checkout commit\n\n'
      hashes --all
      ;;
    refs)
      echo $'⌥D diff ╱ ⌃O checkout ref\n⌃F show all refs\n'
      refs 'grep -v ^refs/remotes'
      ;;
    all-refs)
      echo $'⌥D diff ╱ ⌃O checkout ref\n\n'
      refs 'cat'
      ;;
    nobeep) ;;
    *) exit 1 ;;
  esac
elif [[ $# -gt 1 ]]; then
  set -e

  branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  if [[ $branch = HEAD ]]; then
    branch=$(git describe --exact-match --tags 2> /dev/null || git rev-parse --short HEAD)
  fi

  # Only supports GitHub for now
  case "$1" in
    commit)
      hash=$(grep -o "[a-f0-9]\{7,\}" <<< "$2")
      path=/commit/$hash
      ;;
    branch|remote-branch)
      branch=$(sed 's/^[* ]*//' <<< "$2" | cut -d' ' -f1)
      remote=$(git config branch."${branch}".remote || echo 'origin')
      branch=${branch#$remote/}
      path=/tree/$branch
      ;;
    remote)
      remote=$2
      path=/tree/$branch
      ;;
    file) path=/blob/$branch/$(git rev-parse --show-prefix)$2 ;;
    tag)  path=/releases/tag/$2 ;;
    *)    exit 1 ;;
  esac

  remote=${remote:-$(git config branch."${branch}".remote || echo 'origin')}
  remote_url=$(git remote get-url "$remote" 2> /dev/null || echo "$remote")

  if [[ $remote_url =~ ^git@ ]]; then
    url=${remote_url%.git}
    url=${url#git@}
    url=https://${url/://}
  elif [[ $remote_url =~ ^http ]]; then
    url=${remote_url%.git}
  fi

  case "$(uname -s)" in
    Darwin) open "$url$path"     ;;
    *)      xdg-open "$url$path" ;;
  esac
  exit 0
elif [[ -n "$type" && -n "$TMUX" ]]; then
  cwd=$(tmux display -p "#{pane_current_path}")
  cd $cwd

  case $type in
    files)
      pane=$(tmux display -p "#P")
      files=()
      _fzf_git_files | while read -r file; do
        files+=("$file")
      done
      [ -n "$files" ] && open_in_nvim $files || exit 0
      ;;
    *)
      _fzf_git_$type; exit 0 ;;
  esac
fi
