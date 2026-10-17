function stripaudio --description 'Remove audio track from a video file'
    if test (count $argv) -eq 0 -o "$argv[1]" = --help -o "$argv[1]" = -h
        echo "Usage: stripaudio <input> [output]"
        echo ""
        echo "Remove the audio track from a video file."
        echo "Output defaults to <name>_noaudio.<ext> if not specified."
        return 0
    end

    set input $argv[1]

    if not test -f $input
        echo "Error: file not found: $input"
        return 1
    end

    if test (count $argv) -ge 2
        set output $argv[2]
    else
        set ext (string match -r '\.[^.]+$' $input)
        set base (string replace -r '\.[^.]+$' '' $input)
        set output $base"_noaudio"$ext
    end

    ffmpeg -y -i $input -c:v copy -an $output

    if test $status -eq 0
        set size_kb (math --scale=1 (stat -c%s $output) / 1024)
        echo ""
        echo "Done: $output ($size_kb KB)"
    else
        echo "Error: ffmpeg failed"
        return 1
    end
end
