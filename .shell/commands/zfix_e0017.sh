#!/bin/sh

F="/opt/klipper/klippy/toolhead.py"

already_done() {
    echo "Already done!"
    exit 1
}

if [ "$1" = "0" ]; then
    echo "Reverting LOOKAHEAD_FLUSH_TIME"

    grep -qe "^LOOKAHEAD_FLUSH_TIME = 0.5" $F \
        && already_done
    
    sed -i 's|^LOOKAHEAD_FLUSH_TIME.*|LOOKAHEAD_FLUSH_TIME = 0.5|' $F
else
    echo "Patching LOOKAHEAD_FLUSH_TIME"

    grep -qe "^LOOKAHEAD_FLUSH_TIME = 0.150" $F \
        && already_done
    
    sed -i 's|^LOOKAHEAD_FLUSH_TIME.*|LOOKAHEAD_FLUSH_TIME = 0.150|' $F
fi

echo "Done"
sync
