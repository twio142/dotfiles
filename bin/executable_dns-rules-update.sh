#!/bin/zsh

url1=https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
# url2=https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-domains.txt

forward=/opt/homebrew/etc/dnscrypt-proxy/forwarding-rules.txt
# block=/opt/homebrew/etc/dnscrypt-proxy/blocked-names.txt

list=$(curl -s $url1)
[ -z "$list" ] && {echo Error; exit 1}
echo $list | grep -v '^#' | perl -pe 's/^.+?\/(.+?)\/.+/\1 119.29.29.29,114.114.114.114/g' > $forward
# curl -s $url2 | grep -v '^#' | perl -pe 's/^.+?\/(.+?)\//\1/g' > $block
