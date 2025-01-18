#!/bin/zsh
## Organize new files in ~/Downloads based on their MIME types or extensions.
## Works with Folder Action Script.

export PATH=/opt/homebrew/bin:$PATH

move() {
    [[ -e "$1" && -d "$2" ]] || return 1
    osascript -e 'on run argv
    set theFile to POSIX file (item 1 of argv) as alias
    tell application "Finder" to move theFile to (POSIX file (item 2 of argv) as alias)
end run' "$1" "$2"
}

for file in "$@"; do
    mime=$(file --mime-type -b "$file")
    if [[ "$mime" =~ "^application/(x-)?(g?zip|tar|bzip*|7z-compressed|xz|rar)$" ]]; then
        ouch decompress "$file" || open "$file"
    elif [[ "${file:e}" =~ "^(dmg|alfredworkflow5?|pkg|epub|ics)" ]]; then
        open "$file"
    elif [[ "${file:e}" =~ "^(ass|srt|sub)" ]] || [[ -d "$file" && -n "$(fd -e ass -e srt -e sub . $file)" ]]; then
        move "$file" ~/Movies
    elif [[ "$mime" =~ "^video/" || "${file:e}" = mkv ]]; then
        move "$file" ~/Movies
    elif [[ "$mime" =~ "^audio/" ]]; then
        music_dir=$(fd -td 'Automatically Add to Music.localized' ~/Music)
        duration=$(ffprobe -i "$file" -show_entries format=duration -v quiet -of csv="p=0")
        if [ -d "$music_dir" ] && (( ${duration%.*} >= 30 )); then
            osascript -e 'on run argv
    display dialog "Import " & (quoted form of (item 1 of argv)) & " to the Music library?" with icon alias "Macintosh HD:System:Applications:Music.app:Contents:Resources:AppIcon.icns" buttons {"No", "Yes"} default button "Yes" cancel button "No"
end run' "${file:t}" && move "$file" "$music_dir"
        fi
    fi
done
