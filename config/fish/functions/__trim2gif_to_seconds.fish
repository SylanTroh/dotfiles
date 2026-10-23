function __trim2gif_to_seconds
    set t $argv[1]
    if string match -qr '^[0-9]+(:[0-9.]+)+$' -- $t
        echo $t | awk -F: '{s=0; for(i=1;i<=NF;i++) s=s*60+$i; print s}'
    else
        echo $t
    end
end
