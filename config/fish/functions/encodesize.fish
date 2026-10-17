function encodesize --description "Encode a video to fit within a target file size"
    if test (count $argv) -lt 2 -o (count $argv) -gt 3
        echo "Usage: encodesize <size[KB|MB|GB]> <input> [output]"
        echo "  Examples: encodesize 10MB input.mp4"
        echo "            encodesize 50000KB input.mp4"
        echo "            encodesize 1GB input.mp4 out.mp4"
        return 1
    end

    set size_arg $argv[1]
    set input $argv[2]

    if not test -f $input
        echo "Error: file not found: $input"
        return 1
    end

    set size_num (string replace -ri '[a-z]+$' '' $size_arg)
    set size_unit (string match -ri '[a-z]+$' $size_arg)

    switch (string upper $size_unit)
        case KB
            set target_bytes (math "$size_num * 1000")
        case MB ''
            set target_bytes (math "$size_num * 1000 * 1000")
        case GB
            set target_bytes (math "$size_num * 1000 * 1000 * 1000")
        case '*'
            echo "Error: unrecognised unit '$size_unit' — use KB, MB, or GB"
            return 1
    end

    if test (count $argv) -eq 3
        set output $argv[3]
    else
        set ext (string match -r '\.[^.]+$' $input)
        set base (string replace -- $ext '' $input)
        set output $base"_"(string lower $size_arg)".mp4"
    end

    set duration (ffprobe -v error -show_entries format=duration -of csv=p=0 $input 2>/dev/null)
    if test -z "$duration"
        echo "Error: could not determine video duration"
        return 1
    end

    set audio_bps 0
    set audio_opts -an
    if test -n "$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 $input 2>/dev/null)"
        set audio_bps 128000
        set audio_opts -c:a aac -b:a $audio_bps
    end

    # Leave 2% for overhead
    set total_bps (math --scale=0 "$target_bytes * 8 * 0.98 / $duration")
    set video_bps (math "$total_bps - $audio_bps")

    if test $video_bps -le 0
        echo "Error: video is too long to fit in $size_arg at acceptable quality"
        return 1
    end

    set tmpdir (mktemp -d /tmp/encodesize.XXXXXX)

    for attempt in 1 2 3
        set bufsize (math --scale=0 "$video_bps * 2")

        # Fallback
        if test $attempt -eq 3
            set video_bps (math --scale=0 "($target_bytes * 8 * 0.98 - $audio_bps * $duration) / ($duration + 0.5)")
            set bufsize (math --scale=0 "$video_bps / 2")
        end

        echo "Attempt $attempt: duration $duration s | video "(math --scale=0 $video_bps / 1000)" kbps | audio "(math $audio_bps / 1000)" kbps"

        set rate -b:v $video_bps -maxrate $video_bps -bufsize $bufsize
        ffmpeg -v error -stats -y -i $input -c:v libx264 -preset medium $rate \
            -pass 1 -passlogfile $tmpdir/pass -an -f null /dev/null
        and ffmpeg -v error -stats -y -i $input -c:v libx264 -preset medium $rate \
            -pass 2 -passlogfile $tmpdir/pass $audio_opts -movflags +faststart $output
        or begin
            echo "Error: ffmpeg failed"
            rm -rf $tmpdir
            return 1
        end

        set size (stat -c%s $output)
        if test $size -le $target_bytes
            rm -rf $tmpdir
            echo ""
            echo "Done: $output ("(math --scale=1 $size / 1000)" KB of "(math --scale=1 $target_bytes / 1000)" KB)"
            return 0
        end

        echo "Too big ("(math --scale=1 $size / 1000)" KB), retrying with a lower bitrate..."
        set video_bps (math --scale=0 "$video_bps * $target_bytes / $size * 0.97")
    end

    rm -rf $tmpdir
    echo "Error: could not get under $size_arg; $output is "(math --scale=1 $size / 1000)" KB"
    return 1
end
