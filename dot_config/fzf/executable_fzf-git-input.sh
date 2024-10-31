#!/opt/homebrew/bin/bash

git_current_branch() { git rev-parse --abbrev-ref HEAD; }
g() { git "$@"; }
ga() { git add "$@"; }
gaa() { git add --all "$@"; }
gap() { git apply "$@"; }
gb() { git branch "$@"; }
gbD() { git branch --delete --force "$@"; }
gba() { git branch --all "$@"; }
gbd() { git branch --delete "$@"; }
gbm() { git branch --move "$@"; }
gbnm() { git branch --no-merged "$@"; }
gbr() { git branch --remote "$@"; }
gcB() { git checkout -B "$@"; }
gcam() { git commit --all --message "$@"; }
gcb() { git checkout -b "$@"; }
gcd() { git checkout $(git_develop_branch) "$@"; }
gcl() { git clone --recurse-submodules "$@"; }
gcm() { git checkout $(git_main_branch) "$@"; }
gco() { git checkout "$@"; }
gcor() { git checkout --recurse-submodules "$@"; }
gcp() { git cherry-pick "$@"; }
gcpa() { git cherry-pick --abort "$@"; }
gcpc() { git cherry-pick --continue "$@"; }
gd() { git diff "$@"; }
gf() { git fetch "$@"; }
gfa() { git fetch --all --prune --jobs=10 "$@"; }
gfo() { git fetch origin "$@"; }
ggpull() { git pull origin "$(git_current_branch)" "$@"; }
gl() { git pull "$@"; }
gluc() { git pull upstream $(git_current_branch) "$@"; }
glum() { git pull upstream $(git_main_branch) "$@"; }
gm() { git merge "$@"; }
gma() { git merge --abort "$@"; }
gmc() { git merge --continue "$@"; }
gmom() { git merge origin/$(git_main_branch) "$@"; }
gms() { git merge --squash "$@"; }
gmum() { git merge upstream/$(git_main_branch) "$@"; }
gp() { git push "$@"; }
gpd() { git push --dry-run "$@"; }
gpr() { git pull --rebase "$@"; }
gpra() { git pull --rebase --autostash "$@"; }
gprav() { git pull --rebase --autostash -v "$@"; }
gprom() { git pull --rebase origin $(git_main_branch) "$@"; }
gpromi() { git pull --rebase=interactive origin $(git_main_branch) "$@"; }
gprv() { git pull --rebase -v "$@"; }
gpu() { git push upstream "$@"; }
gr() { git remote "$@"; }
gra() { git remote add "$@"; }
grb() { git rebase "$@"; }
grba() { git rebase --abort "$@"; }
grbc() { git rebase --continue "$@"; }
grbd() { git rebase $(git_develop_branch) "$@"; }
grbi() { git rebase --interactive "$@"; }
grbm() { git rebase $(git_main_branch) "$@"; }
grbo() { git rebase --onto "$@"; }
grbom() { git rebase origin/$(git_main_branch) "$@"; }
grbs() { git rebase --skip "$@"; }
grev() { git revert "$@"; }
greva() { git revert --abort "$@"; }
grevc() { git revert --continue "$@"; }
grh() { git reset "$@"; }
grm() { git rm "$@"; }
grmc() { git rm --cached "$@"; }
grmv() { git remote rename "$@"; }
groh() { git reset origin/$(git_current_branch) --hard "$@"; }
grrm() { git remote remove "$@"; }
grs() { git restore "$@"; }
grset() { git remote set-url "$@"; }
grss() { git restore --source "$@"; }
grst() { git restore --staged "$@"; }
grup() { git remote update "$@"; }
grv() { git remote --verbose "$@"; }
gsb() { git status --short --branch "$@"; }
gsi() { git submodule init "$@"; }
gss() { git status --short "$@"; }
gst() { git status "$@"; }
gsta() { git stash push "$@"; }
gstaa() { git stash apply "$@"; }
gstall() { git stash --all "$@"; }
gstc() { git stash clear "$@"; }
gstd() { git stash drop "$@"; }
gstl() { git stash list "$@"; }
gstp() { git stash pop "$@"; }
gsts() { git stash show --patch "$@"; }
gsu() { git submodule update "$@"; }
gsw() { git switch "$@"; }
gswc() { git switch --create "$@"; }
gswd() { git switch $(git_develop_branch) "$@"; }
gswm() { git switch $(git_main_branch) "$@"; }
gta() { git tag --annotate "$@"; }
gts() { git tag --sign "$@"; }
gtv() { git tag | sort -V "$@"; }
gwt() { git worktree "$@"; }
gwta() { git worktree add "$@"; }
gwtls() { git worktree list "$@"; }
gwtmv() { git worktree move "$@"; }
gwtrm() { git worktree remove "$@"; }

files=
for i in "$@"; do
  case $mode in
    stash) files+="$(echo $i | cut -d: -f1)" ;;
    hash) files+="$(echo $i | grep -Eo '[a-f0-9]{7,}.+' | awk '{print $1}') " ;;
    *) files+="$(printf '%q' "$i") " ;;
  esac
done

cliclick kd:ctrl t:a ku:ctrl &
read -e -i " $files" -r user_input

check () {
  local a=$(echo $1 | sed 's/(^\s*|\s*$)//g')
  local b=$(echo $2 | sed 's/(^\s*|\s*$)//g')
  [ "$a" == "$b" ] && return 1 || return 0
}

if (check "$files" "$user_input"); then 
  msg=$(eval "${user_input}" 2>&1)
  [ -z "$msg" ] || tmux display-message "$msg"
else
  exit 0
fi
