#!/bin/sh

F="/opt/klipper/klippy/toolhead.py"


if [ "$1" = "0" ]; then
    echo "0"
    grep -qe "^LOOKAHEAD_FLUSH_TIME = 0.5" $F \
        && exit 1
    
    sed -i 's|^LOOKAHEAD_FLUSH_TIME.*|LOOKAHEAD_FLUSH_TIME = 0.5|' $F
else
    echo "1"
    grep -qe "^LOOKAHEAD_FLUSH_TIME = 0.150" $F \
        && exit 1
    
    sed -i 's|^LOOKAHEAD_FLUSH_TIME.*|LOOKAHEAD_FLUSH_TIME = 0.150|' $F
fi

sync
