#!/bin/bash

unset LD_PRELOAD
unset LD_LIBRARY_PATH

[ $# -eq 1 ] && /usr/bin/python /root/printer_data/scripts/zsend.py "$1"
if [ $# -eq 2 ]
    then
        M109=$(head -1000 "/data/$2" | grep "^M109" | head -1)
        [ "$M109" == "" ] && M109=$(head -1000 "/data/$2" | grep "^M104" | head -1 | sed 's|M104|M109|')
        M190=$(head -1000 "/data/$2" | grep "^M190" | head -1)
        [ "$M190" == "" ] && M190=$(head -1000 "/data/$2" | grep "^M140" | head -1 | sed 's|M140|M190|')

        if [ "$M190" == "" ] || [ "$M109" == "" ]
            then
                echo "RESPOND TYPE=error MSG=\"В файле $2 не найдены команды нагрева стола(M140/M190) или сопла(M104/M109).\"" >/tmp/printer
                exit 1
            else
                RET=$(/usr/bin/python /root/printer_data/scripts/zsend.py "M23" "$2")
                echo -e "$RET"
        fi
fi
