function encode10mb --wraps encodesize --description "Encode a video to fit within a 10MB file size limit"
    encodesize 10MB $argv
end
