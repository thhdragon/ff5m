#!/bin/sh
#
# Web config
#

WEB="fluidd"
grep -q "CLIENT=$WEB" /opt/config/mod_data/web.conf && WEB="mainsail"

echo "# Не редактируйте этот файл
# Используйте макрос
#
# WEB

# Веб интерфейс (fluidd|mainsail)
CLIENT=$WEB
" >/opt/config/mod_data/web.conf

sync
reboot
