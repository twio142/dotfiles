require 'mp'

function set_clipboard(text)
    mp.command_native({name='subprocess', stdin_data=text, args={"pbcopy"}})
end

local function copy_time()
    local time_pos = mp.get_property_number("time-pos")
    local time_in_seconds = time_pos
    local time_seg = time_pos % 60
    time_pos = time_pos - time_seg
    local time_hours = math.floor(time_pos / 3600)
    time_pos = time_pos - (time_hours * 3600)
    local time_minutes = time_pos/60
    time_seg,time_ms=string.format("%.03f", time_seg):match"([^.]*).(.*)"
    -- time = string.format("%02d:%02d:%02d.%s", time_hours, time_minutes, time_seg, time_ms)
    time = string.format("%02d:%02d:%02d", time_hours, time_minutes, time_seg):gsub("^00:", "")
    mp.osd_message(string.format("Timestamp Copied: %s", time))
    set_clipboard(time)
end

local function help()
    mp.commandv("run", "osascript", "-l", "JavaScript", "-e", 'Application("com.runningwithcrayons.Alfred").runTrigger("iina_help", {inWorkflow:"com.nyako520.media"})')
end

mp.add_key_binding("Ctrl+c", "copy-time", copy_time)
mp.add_key_binding("?", "show-help", help)
