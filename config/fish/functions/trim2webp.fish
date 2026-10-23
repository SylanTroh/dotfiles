function trim2webp --description "Trim a video segment and encode to animated WebP"
    set input ""
    set start ""
    set end_time ""
    set output ""
    set quality 70
    set fps 15
    set size 480
    set scale ""
    set length ""
    set pick_mode false

    while test (count $argv) -gt 0
        switch $argv[1]
            case --start
                set start $argv[2]
                set argv $argv[2..-1]
            case --end
                set end_time $argv[2]
                set argv $argv[2..-1]
            case --output
                set output $argv[2]
                set argv $argv[2..-1]
            case --quality
                set quality $argv[2]
                set argv $argv[2..-1]
            case --fps
                set fps $argv[2]
                set argv $argv[2..-1]
            case --size
                set size $argv[2]
                set argv $argv[2..-1]
            case --scale
                set scale $argv[2]
                set argv $argv[2..-1]
            case --length
                set length $argv[2]
                set argv $argv[2..-1]
            case --pick
                set pick_mode true
            case -e -h --help
                echo "Usage: trim2webp <input> [options]"
                echo ""
                echo "Trim a video segment and encode to an animated WebP."
                echo ""
                echo "Options:"
                echo "  --start <time>    Start time (HH:MM:SS or seconds)"
                echo "  --end <time>      End time (HH:MM:SS or seconds)"
                echo "  --pick            Pick start/end in mpv ([s] start, [e] end, [q] done)"
                echo "  --output <file>   Output filename (default: <name>_trimmed.webp)"
                echo "  --quality <n>     WebP quality (0=smallest..100=best, default: 70)"
                echo "  --fps <n>         Frame rate to sample from the source (default: 15)"
                echo "  --size <n>        Max width/height in pixels (default: 480)"
                echo "  --scale <expr>    Custom scale filter, overrides --size"
                echo "  --length <secs>   Play the trimmed segment in this many seconds (speeds up/slow down)"
                echo "  -h, --help        Show this help"
                return 0
            case '*'
                if string match -rq '^-' -- $argv[1]
                    echo "Unknown option: $argv[1]"
                    return 1
                end
                if test -z "$input"
                    set input $argv[1]
                end
        end
        set argv $argv[2..-1]
    end

    if test -z "$input"
        echo "Usage: trim2webp <input> [options]"
        return 1
    end

    if not test -f $input
        echo "Error: file not found: $input"
        return 1
    end

    if test $pick_mode = true
        __trim_pick $input
        or return 1
        set start $__trim_pick_start
        set end_time $__trim_pick_end
    end

    if test -z "$output"
        set base (string replace -r '\.[^.]+$' '' $input)
        set output $base"_trimmed.webp"
    end

    set speed 1
    if test -n "$length"
        set start_s 0
        if test -n "$start"
            set start_s (__trim2gif_to_seconds $start)
        end
        if test -n "$end_time"
            set end_s (__trim2gif_to_seconds $end_time)
        else
            set end_s (ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $input)
            if test -z "$end_s" -o $status -ne 0
                echo "Error: could not get duration of $input"
                return 1
            end
        end
        if not string match -qr '^[0-9]*\.?[0-9]+$' -- $length; or test (math $length) = 0
            echo "Error: --length must be a positive number"
            return 1
        end
        set speed (math --scale=4 "($end_s - $start_s) / $length")
    end

    if test -z "$scale"
        set scale "scale='if(gt(iw,ih),$size,-2)':'if(gt(iw,ih),-2,$size)':flags=lanczos"
    end

    set trim
    if test -n "$start"
        set -a trim -ss $start
    end
    if test -n "$end_time"
        set -a trim -to $end_time
    end

    echo "Input:  $input"
    echo "Output: $output"
    echo "Range:  "(string join ' → ' -- $start $end_time)
    echo "Quality (0-100): $quality | Sample FPS: $fps | Scale: $scale"
    if test $speed != 1
        echo "Speed:  x$speed (segment plays in $length s)"
    end

    set video_filter "setpts=PTS/$speed,fps="(math "$fps * $speed")",$scale"

    echo "Encoding WebP..."
    ffmpeg -y $trim -i $input -vf "$video_filter" -c:v libwebp_anim -loop 0 -quality $quality -compression_level 6 -an $output
    if test $status -ne 0
        echo "Error: encoding failed"
        return 1
    end

    set size_kb (math --scale=1 (stat -c%s $output) / 1024)
    echo ""
    echo "Done: $output ($size_kb KB)"
end
