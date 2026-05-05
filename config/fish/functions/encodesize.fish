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
            set target_size_kb $size_num
        case MB ''
            set target_size_kb (math "$size_num * 1024")
        case GB
            set target_size_kb (math "$size_num * 1024 * 1024")
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

    set audio_bitrate_kbps 128

    set duration (ffprobe -v error -show_entries format=duration -of csv=p=0 $input 2>/dev/null)
    if test -z $duration
        echo "Error: could not determine video duration"
        return 1
    end

    set total_bitrate (math --scale=0 "$target_size_kb * 8 / $duration")
    set video_bitrate (math "$total_bitrate - $audio_bitrate_kbps")

    if test $video_bitrate -le 0
        echo "Error: video is too long to fit in $size_arg at acceptable quality"
        return 1
    end

    echo "Duration: $duration s | Video bitrate: $video_bitrate kbps | Audio: $audio_bitrate_kbps kbps"
    echo "Output: $output"

    ffmpeg -y -i $input -c:v h264_nvenc -b:v $video_bitrate"k" -pass 1 -an -f null /dev/null
    and ffmpeg -y -i $input -c:v h264_nvenc -b:v $video_bitrate"k" -pass 2 -c:a aac -b:a $audio_bitrate_kbps"k" $output

    if test $status -eq 0
        set size_kb (math --scale=1 (stat -c%s $output)" / 1024")
        echo "Done: $output ($size_kb KB)"
    end
end
