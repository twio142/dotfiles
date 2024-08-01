#!/bin/zsh

[ -z $XDG_CONFIG_HOME ] && export XDG_CONFIG_HOME="$HOME/.config"
[ -z $XDG_DATA_HOME ] && export XDG_DATA_HOME="$HOME/.local/share"
[ -z $XDG_CACHE_HOME ] && export XDG_CACHE_HOME="$HOME/.cache"
[ -z $XDG_STATE_HOME ] && export XDG_STATE_HOME="$HOME/.state"

echo "Installing homebrew & packages"
command -v brew &> /dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
BREWFILE="$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")/Brewfile"
brew bundle check --file $BREWFILE || brew bundle --file $BREWFILE -q

echo "Installing oh-my-zsh & plugins"
[ -z $ZSH ] && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mkdir -p $XDG_CONFIG_HOME/omz-custom/plugins
git clone https://github.com/gretzky/auto-color-ls $XDG_CONFIG_HOME/omz-custom/plugins/auto-color-ls 2> /dev/null
git clone https://github.com/z-shell/F-Sy-H.git $XDG_CONFIG_HOME/omz-custom/plugins/F-Sy-H 2> /dev/null

echo "Installing SpaceVim"
curl -sLf "https://spacevim.org/install.sh" | bash

echo "Installing Hammerspoon configs"
mkdir -p $XDG_CONFIG_HOME/hammerspoon
git clone git@github.com:twio142/hammerspoon.git $XDG_CONFIG_HOME/hammerspoon 2> /dev/null
