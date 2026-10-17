function __trim_pick --description 'Pick trim points in mpv; sets $__trim_pick_start and $__trim_pick_end'
    set -l tmpfile (mktemp /tmp/trim_pick_ts.XXXXXX)

    echo "Opening video picker for: $argv[1]"
    echo "  [s] mark start  [e] mark end  [q]/[Esc] finish"
    echo ""

    mpv --no-config \
        --script=$__fish_config_dir/scripts/trim_picker.lua \
        --script-opts=trim_picker-file=$tmpfile \
        --loop-file=inf \
        --no-terminal \
        $argv[1]

    set -l times (cat $tmpfile)
    rm -f $tmpfile

    # The picker writes "0 0" until both points are marked
    if test (count $times) -lt 2; or test "$times[2]" = 0
        echo "Error: no trim points selected"
        return 1
    end

    set -g __trim_pick_start $times[1]
    set -g __trim_pick_end $times[2]
    echo "Selected: $__trim_pick_start → $__trim_pick_end"
    echo ""
end
