#!/bin/bash

source /opt/config/mod/.shell/common.sh

F="/opt/klipper/klippy/toolhead.py"

already_done() {
    echo "E0017 fix already applied!"
    exit 1
}

fix_disable() {
    echo "Reverting LOOKAHEAD_FLUSH_TIME"

    grep -qe "^LOOKAHEAD_FLUSH_TIME = 0.5" $F \
        && already_done
    
    sed -i 's|^LOOKAHEAD_FLUSH_TIME.*|LOOKAHEAD_FLUSH_TIME = 0.5|' $F

    sync
    echo "Done"
}

fix_enable() {
    echo "Patching LOOKAHEAD_FLUSH_TIME"

    grep -qe "^LOOKAHEAD_FLUSH_TIME = 0.150" $F \
        && already_done
    
    sed -i 's|^LOOKAHEAD_FLUSH_TIME.*|LOOKAHEAD_FLUSH_TIME = 0.150|' $F

    sync
    echo "Done"
}

fix_apply() {
    local enabled="$($CFG_SCRIPT "$VAR_PATH" --get "fix_e0017" "0")"
    if [ "$enabled" == "1" ]; then
        fix_enable
    else
        fix_enable
    fi
}

case "$1" in
    0)
        fix_disable
    ;;
    1)
        fix_enable
    ;;
    apply)
        fix_apply
    ;;
    *)
        echo "Command not supported"
        exit 1
esac
