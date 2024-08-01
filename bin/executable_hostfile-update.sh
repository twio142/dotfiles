#!/bin/zsh
tmp=$(mktemp -d)
# curl -sL http://sbc.io/hosts/hosts -o $tmp/hosts.hst
curl -sL https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts -o $tmp/hosts.hst
[ -s $tmp/hosts.hst ] && sudo mv $tmp/hosts.hst /etc/hosts || echo Error
rm -rf $tmp
