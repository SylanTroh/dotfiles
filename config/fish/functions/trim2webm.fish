function trim2webm --description "Trim a video segment and encode to WebM (VP9 or AV1)"
    set input ""
    set start ""
    set end_time ""
    set output ""
    set quality ""
    set codec libvpx-vp9
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
            case --pick
                set pick_mode true
            case --av1
                set codec libsvtav1
            case --vp9
                set codec libvpx-vp9
            case -e -h --help
                echo "Usage: trim2webm <input> [options]"
                echo ""
                echo "Trim a video segment and encode to WebM."
                echo ""
                echo "Options:"
                echo "  --start <time>    Start time (HH:MM:SS or seconds)"
                echo "  --end <time>      End time (HH:MM:SS or seconds)"
                echo "  --pick            Pick start/end in mpv ([s] start, [e] end, [q] done)"
                echo "  --output <file>   Output filename (default: <name>_trimmed.webm)"
                echo "  --quality <n>     CRF quality (0-63, lower is better)"
                echo "  --av1             Encode AV1 instead of VP9"
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
        echo "Usage: trim2webm <input> [options]"
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
        set output $base"_trimmed.webm"
    end

    set trim
    if test -n "$start"
        set -a trim -ss $start
    end
    if test -n "$end_time"
        set -a trim -to $end_time
    end

    set codec_opts
    if test $codec = libvpx-vp9
        test -z "$quality"; and set quality 31
        set codec_opts -row-mt 1
    else
        test -z "$quality"; and set quality 23
    end

    echo "Input:  $input"
    echo "Output: $output"
    echo "Range:  "(string join ' → ' -- $start $end_time)
    echo "Codec:  $codec (CRF $quality)"
    echo ""
    echo "Encoding..."

    ffmpeg -y $trim -i $input -c:v $codec $codec_opts -crf $quality -b:v 0 -c:a libopus -b:a 128k $output

    if test $status -eq 0
        set size_kb (math --scale=1 (stat -c%s $output) / 1024)
        echo ""
        echo "Done: $output ($size_kb KB)"
    else
        echo "Error: encoding failed"
        return 1
    end
end
