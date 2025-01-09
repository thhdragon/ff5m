#!/bin/sh

APP="/opt/Python-3.7.11/bin/python3 /root/printer_data/scripts/whconsole.py"

FILE_NAME=${1}
if [ -z "${FILE_NAME}" ]; then
    SCRIPT='
{"id": 1, "method": "gcode/script", "params": {"script": "SET_GCODE_VARIABLE MACRO=CHECK_MD5 VARIABLE=success VALUE=1"}}
{"id": 2, "method": "gcode/script", "params": {"script": "CANCEL_PRINT"}}
{"id": 8888, "method": "gcode/script", "params": {"script": "RESPOND TYPE=error MSG=\"Ошибка: Файл \\\"'${FILE_NAME##*/}'\\\" не указан. Печать отменена.\""}}
{"id": -8888}
'
  /bin/echo "${SCRIPT}"|${APP} /tmp/uds -- -8888 &>/dev/null
  exit 1
elif [ ! -f "${FILE_NAME}" ]; then
    SCRIPT='
{"id": 1, "method": "gcode/script", "params": {"script": "SET_GCODE_VARIABLE MACRO=CHECK_MD5 VARIABLE=success VALUE=2"}}
{"id": 2, "method": "gcode/script", "params": {"script": "CANCEL_PRINT"}}
{"id": 8888, "method": "gcode/script", "params": {"script": "RESPOND TYPE=error MSG=\"Ошибка: Файл \\\"'${FILE_NAME##*/}'\\\" не найден. Печать отменена.\""}}
{"id": -8888}
'
  /bin/echo "${SCRIPT}"|${APP} /tmp/uds -- -8888 &>/dev/null
  exit 2
fi

DELETE_FILE=${2}
if [ -z "${DELETE_FILE}" ]; then
  DELETE_FILE="false"
fi

ORIG_MD5="$(/usr/bin/awk -F: '/; MD5/{printf("%s", $2)}' "${FILE_NAME}"|/usr/bin/tr -d ' \r')"
if [ -z "${ORIG_MD5}" ]
    then
        SCRIPT='
{"id": 1, "method": "gcode/script", "params": {"script": "SET_GCODE_VARIABLE MACRO=CHECK_MD5 VARIABLE=success VALUE=3"}}
{"id": 8888, "method": "gcode/script", "params": {"script": "RESPOND TYPE=error MSG=\"В файле \\\"'${FILE_NAME##*/}'\\\" нет MD5 суммы. Включите ее в Orca.\""}}
{"id": -8888}
'
    /bin/echo "${SCRIPT}"|${APP} /tmp/uds -- -8888 &>/dev/null
    exit 3
fi

LOCAL_MD5="$(/bin/cat "${FILE_NAME}"|/bin/grep -v '^; MD5:'|/usr/bin/md5sum|/usr/bin/tr -d ' -')"

if grep -q 'G2 ' "${FILE_NAME}" || grep -q 'G3 ' "${FILE_NAME}"
    then
        SCRIPT='
{"id": 8888, "method": "gcode/script", "params": {"script": "RESPOND TYPE=echo MSG=\"В файле \\\"'${FILE_NAME##*/}'\\\" найдено использование дуг(G2, G3). Отключите их. В Orca: Профиль процесса -> Аппроксимация дугами. Убрать галочку.\""}}
{"id": -8888}
'
  /bin/echo "${SCRIPT}"|${APP} /tmp/uds -- -8888 &>/dev/null
fi

if [ "_${LOCAL_MD5}" = "_${ORIG_MD5}" ]
    then
        SCRIPT='
{"id": 8888, "method": "gcode/script", "params": {"script": "RESPOND TYPE=echo MSG=\"Notice: MD5 сумма файла \\\"'${FILE_NAME##*/}'\\\" проверена успешно\""}}
{"id": -8888}
'
else
    if [ "true" = "${DELETE_FILE}" ] || [ "True" = "${DELETE_FILE}" ]
        then
            /bin/rm -f "${FILE_NAME}"
            SCRIPT='
{"id": 1, "method": "gcode/script", "params": {"script": "SET_GCODE_VARIABLE MACRO=CHECK_MD5 VARIABLE=success VALUE=4"}}
{"id": 2, "method": "gcode/script", "params": {"script": "CANCEL_PRINT"}}
{"id": 8888, "method": "gcode/script", "params": {"script": "RESPOND TYPE=error MSG=\"Ошибка: MD5 сумма не совпала для файла \\\"'${FILE_NAME##*/}'\\\". Файл удален. Печать отменена.\""}}
{"id": -8888}
'
        else
    SCRIPT='
{"id": 1, "method": "gcode/script", "params": {"script": "SET_GCODE_VARIABLE MACRO=CHECK_MD5 VARIABLE=success VALUE=5"}}
{"id": 2, "method": "gcode/script", "params": {"script": "CANCEL_PRINT"}}
{"id": 8888, "method": "gcode/script", "params": {"script": "RESPOND TYPE=error MSG=\"Ошибка: MD5 сумма не совпала для файла \\\"'${FILE_NAME##*/}'\\\". Печать отменена.\""}}
{"id": -8888}
'
    fi
fi

  /bin/echo "${SCRIPT}"|${APP} /tmp/uds -- -8888 &>/dev/null
exit 0
