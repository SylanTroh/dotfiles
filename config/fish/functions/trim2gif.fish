function trim2gif --description "Trim a video segment and encode to GIF"
    set input ""
    set start ""
    set end_time ""
    set output ""
    set quality 3
    set fps 15
    set scale "scale=480:-1:flags=lanczos"
    set pick_mode false

    # Parse arguments
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
            case --scale
                set scale $argv[2]
                set argv $argv[2..-1]
            case --pick
                set pick_mode true
            case -e -h --help
                echo "Usage: trim2gif <input> [options]"
                echo ""
                echo "Trim a video segment and encode to an animated GIF."
                echo ""
                echo "Options:"
                echo "  --start <time>    Start time (HH:MM:SS or seconds)"
                echo "  --end <time>      End time (HH:MM:SS or seconds)"
                echo "  --pick            Pick start/end in mpv ([s] start, [e] end, [q] done)"
                echo "  --output <file>   Output filename (default: <name>_trimmed.gif)"
                echo "  --quality <n>     Dither bayer_scale (0=finest..5=coarsest, default: 3)"
                echo "  --fps <n>         Output frame rate (default: 15)"
                echo "  --scale <expr>    Scale expression (default: scale=480:-1:flags=lanczos)"
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
        echo "Usage: trim2gif <input> [options]"
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
        set output $base"_trimmed.gif"
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
    echo "Quality (bayer_scale 0-5): $quality | FPS: $fps | Scale: $scale"

    set palette (mktemp --suffix=.png /tmp/trim2gif_palette_XXXXXX)

    echo "Pass 1: Generating palette..."
    ffmpeg -y $trim -i $input -vf "$scale,palettegen=max_colors=256:stats_mode=diff" -frames:v 1 -update 1 $palette
    if test $status -ne 0
        echo "Error: palette generation failed"
        rm -f $palette
        return 1
    end

    echo "Pass 2: Encoding GIF..."
    ffmpeg -y $trim -i $input -i $palette -lavfi "$scale [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=$quality" -r $fps $output
    set encode_status $status
    rm -f $palette

    if test $encode_status -eq 0
        set size_kb (math --scale=1 (stat -c%s $output) / 1024)
        echo ""
        echo "Done: $output ($size_kb KB)"
    else
        echo "Error: encoding failed"
        return 1
    end
end
