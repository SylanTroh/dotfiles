function encode10mb --description "Encode a video to fit within a 10MB file size limit"
    if test (count $argv) -lt 1 -o (count $argv) -gt 2
        echo "Usage: encode10mb <input> [output]"
        return 1
    end

    set input $argv[1]
    if not test -f $input
        echo "Error: file not found: $input"
        return 1
    end

    if test (count $argv) -eq 2
        set output $argv[2]
    else
        set ext (string match -r '\.[^.]+$' $input)
        set base (string replace -- $ext '' $input)
        set output $base"_10mb.mp4"
    end

    set target_size_kb 10240  # 10MB in kilobytes
    set audio_bitrate_kbps 128

    set duration (ffprobe -v error -show_entries format=duration -of csv=p=0 $input 2>/dev/null)
    if test -z $duration
        echo "Error: could not determine video duration"
        return 1
    end

    # total_bitrate (kbps) = (target_size_kb * 8) / duration
    set total_bitrate (math --scale=0 "$target_size_kb * 8 / $duration")
    set video_bitrate (math "$total_bitrate - $audio_bitrate_kbps")

    if test $video_bitrate -le 0
        echo "Error: video is too long to fit in 10MB at acceptable quality"
        return 1
    end

    echo "Duration: $duration s | Video bitrate: $video_bitrate kbps | Audio: $audio_bitrate_kbps kbps"
    echo "Output: $output"

    # Two-pass encoding for accurate file size targeting
    ffmpeg -y -i $input -c:v h264_nvenc -b:v $video_bitrate"k" -pass 1 -an -f null /dev/null
    and ffmpeg -y -i $input -c:v h264_nvenc -b:v $video_bitrate"k" -pass 2 -c:a aac -b:a $audio_bitrate_kbps"k" $output

    if test $status -eq 0
        set size_kb (math --scale=1 (stat -c%s $output)" / 1024")
        echo "Done: $output ($size_kb KB)"
    end
end
