SCRIPT_PATH=$(dirname $BASH_SOURCE[0])
export PATH="$HOME/.local/bin:/opt/homebrwe/bin:/usr/local/bin:$PATH"
exec nvim --headless --cmd "let g:spare = 1" -c "luafile $SCRIPT_PATH/server.lua"
