#!/bin/bash

unset LD_PRELOAD
unset LD_LIBRARY_PATH


if [ "$#" -eq 1 ]; then
    /usr/bin/python /root/printer_data/py/zsend.py "$1"
    exit
fi

if [ "$#" -eq 2 ]; then
    FILE="/data/$2"
    
    M109=$(head -1000 "$FILE" | grep "^M109" | head -1)
    if [ -z "$M109" ]; then
        M109=$(head -1000 "$FILE" | grep "^M104" | head -1 | sed 's|M104|M109|')
    fi
    
    M190=$(head -1000 "$FILE" | grep "^M190" | head -1)
    if [ -z "$M190" ]; then
        M190=$(head -1000 "$FILE" | grep "^M140" | head -1 | sed 's|M140|M190|')
    fi
    
    if [ -z "$M109" ] || [ -z "$M190" ]; then
        echo "RESPOND TYPE=error MSG=\"В файле $2 не найдены команды нагрева стола(M140/M190) или сопла(M104/M109).\"" > /tmp/printer
        exit 1
    fi
    
    RET=$(/usr/bin/python /root/printer_data/py/zsend.py "M23" "$2")
    echo -e "$RET"
    
    exit
fi

echo 'RESPOND TYPE=error MSG="Неверное количество аргументов"' > /tmp/printer
exit 1