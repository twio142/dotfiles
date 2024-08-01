#!/bin/zsh
# Download audio files from a 看理想 webpage and convert them to 2x speed
# Copy the curl command from the network tab in developer tools
# Be sure to open developer tools in a separate window
# Save file titles in a file named `catalog`

TAB_ID=9AEE7B3E-82FC-4BA1-BAB4-E9EE83AEC280 # tab id of the 看理想 webpage

[ -f catalog ] || { echo "Catalog file not found"; exit 1; }
[ -d 2x ] || mkdir ./2x

speedUp() {
    ffmpeg -i $1.mp3 -filter:a "atempo=2.0" 2x/$1.mp3 > /dev/null 2>> ./error.log || rm -f 2x/$1.mp3
}

while true; do
    next=
    cat catalog | while read t; do
        [ -n "$(find . -name $t.mp3)" ] || { next=$t; break; }
    done
    [ -z $next ] && { echo "All files downloaded."; exit 0; }

    afplay ~/Library/Sounds/octave\ up.aif
    echo "Download $next"

    jxa -e 'run=([i,t])=>{let javascript=`[...document.querySelectorAll("li.li_item")].find(l=>l.querySelector(".infoplayer_title").textContent==${JSON.stringify(t)}).querySelector("i.play").click()`;Application("Arc").windows[0].tabs.byId(i).execute({javascript})}' $TAB_ID "$next" || { echo "Failed to play audio"; exit 1; }

    sleep 1
    hs -A -c "hs.application.get('company.thebrowser.Browser'):getWindow('Developer Tools'):raise()" > /dev/null || { echo 'Developer tool window not found'; exit 1; }
    open -b company.thebrowser.Browser

    prev=$(pbpaste)
    while [ "$(pbpaste)" = "$prev" ]; do
        sleep 1
    done
    cmd=$(pbpaste)

    [[ "$cmd" =~ ^curl ]] || { echo "Invalid curl command"; exit 1; }
    eval "$cmd -s -m 240 -o ./'$next.mp3'" || { rm -f ./"$next.mp3"; continue; }
    nohup speedUp $next &
done
