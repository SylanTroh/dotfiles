-- trim_picker.lua: mpv Lua script for visual trim point selection
--
-- Keys:
--   s  - mark start point
--   e  - mark end point
--   q  / Esc - finish and close

local file_path = mp.get_opt("trim_picker-file") or "/tmp/trim_timestamps.txt"

-- Initialize file with zeros
local f = io.open(file_path, "w")
if f then
    f:write("0\n0\n")
    f:close()
end

local start_marked = false
local end_marked = false

function format_time(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%05.2f", mins, secs)
end

function mark_start()
    start_marked = true
    local t = mp.get_property_number("time-pos", 0)
    local f = io.open(file_path, "w")
    if f then
        f:write(string.format("%.3f\n", t))
        f:close()
    end
    mp.osd_message("Start: " .. format_time(t))
end

function mark_end()
    if not start_marked then
        mp.osd_message("No start point set — press [s] first")
        return
    end
    end_marked = true
    local t = mp.get_property_number("time-pos", 0)
    local start_t = 0
    local f = io.open(file_path, "r")
    if f then
        start_t = tonumber(f:read("*line")) or 0
        f:close()
    end
    f = io.open(file_path, "w")
    if f then
        f:write(string.format("%.3f\n%.3f\n", start_t, t))
        f:close()
    end
    local dur = t - start_t
    mp.osd_message("End: " .. format_time(t) .. " (" .. string.format("%.1fs", dur) .. " duration)")
end

function quit_picker()
    mp.commandv("quit")
end

mp.add_forced_key_binding("s", "mark_start", mark_start)
mp.add_forced_key_binding("e", "mark_end", mark_end)
mp.add_forced_key_binding("q", "quit_picker", quit_picker)
mp.add_forced_key_binding("Q", "quit_picker", quit_picker)
mp.add_forced_key_binding("esc", "quit_picker", quit_picker)

-- Show instructions on load
mp.register_event("file-loaded", function()
    mp.osd_message("Trim Picker: [s] start  [e] end  [q] done")
end)
