#!/bin/zsh
# Merge multiple DNS blocklist files into a single blocked-names.txt file for dnscrypt-proxy.

# Configuration
DIR="$HOME/.config/dnscrypt-proxy/blocklists"
FINAL_FILE="$HOME/.config/dnscrypt-proxy/blocked-names.txt"

BASE_FILE="$DIR/default.txt"

if [[ ! -d "$DIR" || ! -f "$BASE_FILE" ]]; then
  echo "Error: Directory $DIR or base file $BASE_FILE does not exist."
  exit 1
fi

# Read currently opted-in files from FINAL_FILE
current_opted=()
if [[ -f "$FINAL_FILE" ]]; then
  current_opted=($(grep -oE '^###### .+ ######$' "$FINAL_FILE" | sed -E 's/^###### (.+) ######$/\1/'))
fi

# Parse command-line arguments
for arg in "$@"; do
  # Verify the first character is + or -
  if [[ ! "${arg[1]}" =~ [+-] ]]; then
    echo "Invalid argument: $arg. Must start with + or -"
    exit 1
  fi

  file="${arg:1}"                  # Remove + or -
  fullpath="$DIR/$file.txt"        # Append .txt suffix
  if [[ ! -f "$fullpath" ]]; then
    echo "Error: file '$file.txt' not found in $DIR"
    exit 1
  fi

  case "${arg[1]}" in
    "+")
      # Add to opted-in list if not already present
      if [[ "$file" != "default" ]] && [[ ! " ${current_opted[@]} " =~ " $file " ]]; then
        current_opted+="$file"
      fi
      ;;
    "-")
      # Remove from opted-in list
      current_opted=("${current_opted:#$file}")
      ;;
  esac
done

# Generate FINAL_FILE
{
  # Include base file content
  cat "$BASE_FILE"
  echo

  # Include opted-in optional files with comment markers
  for f in "${current_opted[@]}"; do
    file_path="$DIR/$f.txt"
    if [[ ! -f "$file_path" ]]; then
      echo "Warning: opted-in file '$f.txt' not found, skipping." >&2
      continue
    fi
    echo "###### $f ######"
    cat "$file_path"
    echo
  done
} >| "$FINAL_FILE" || {
  echo "Error: failed to write to $FINAL_FILE"
  exit 1
}

echo "Blocklist merged"
echo "Opted-in: ${current_opted[@]}"
