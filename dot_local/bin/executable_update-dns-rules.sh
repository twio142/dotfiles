#!/bin/zsh
# Update dnscrypt-proxy forwarding rules and blocklists

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: $(basename "$0")"
  echo
  echo "Updates dnscrypt-proxy forwarding rules and blocklists."
  echo " - Downloads China-specific domains for forwarding rules."
  echo " - Downloads a master hosts file for the blocklist."
  echo " - Calls 'merge-dns-blocked.sh' to apply the new blocklist."
  exit 0
fi

## Configuration
DIR="$HOME/.config/dnscrypt-proxy"
BLOCK_DIR="$DIR/blocklists"
mkdir -p "$BLOCK_DIR"

## Forwarding rules
FORWARD_FILE="$DIR/forwarding-rules.txt"
FORWARD_URL="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"

TMP_FORWARD=$(mktemp)
trap 'rm -f "$TMP_FORWARD"' EXIT INT TERM

# Try download
if ! curl -sfL "$FORWARD_URL" -o "$TMP_FORWARD"; then
  echo "Error: failed to download forwarding rules, skipping." >&2
else
  # Validate file: must contain at least one line matching server=/domain/IP
  if ! grep -qxE 'server=/[^/]+/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$TMP_FORWARD"; then
    echo "Error: forwarding rules invalid, skipping." >&2
  else
    # Process and write final file
    if ! awk -F'/' '!/^#/ {print $2 " 119.29.29.29,114.114.114.114"}' "$TMP_FORWARD" >| "$FORWARD_FILE"; then
      echo "Error: failed to write $FORWARD_FILE" >&2
    fi
  fi
fi

## Blocklist
BLACKLIST_FILE="$BLOCK_DIR/blacklist.txt"
BLACKLIST_URL="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"

TMP_BLACK=$(mktemp)
trap 'rm -f "$TMP_BLACK"' EXIT INT TERM

# Try download
if ! curl -sfL "$BLACKLIST_URL" -o "$TMP_BLACK"; then
  echo "Error: failed to download blocklist, skipping." >&2
else
  # Validate file: must contain at least one line matching 0.0.0.0 domain
  if ! grep -qxE '0\.0\.0\.0 [^ ]+' "$TMP_BLACK"; then
    echo "Error: blocklist invalid, skipping." >&2
  else
    # Process and write final file
    if ! awk '$1=="0.0.0.0" && $2!="0.0.0.0"{print $2}' "$TMP_BLACK" >| "$BLACKLIST_FILE"; then
      echo "Error: failed to write $BLACKLIST_FILE" >&2
    fi

    # Merge blocklists
    MERGE="merge-dns-blocked.sh"
    if command -v $MERGE &>/dev/null; then
      "$MERGE" +blacklist 1>/dev/null
    else
      echo "Warning: merge-dns-blocked.sh not found or not executable, skipping merge." >&2
    fi
  fi
fi
