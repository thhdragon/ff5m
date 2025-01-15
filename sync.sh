#!/bin/bash

## Synchronize local changes to the printer
##
## Copyright (C) 2025 Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

REMOTE_HOST="$1"
SKIP_RESTART="${2:-0}"
REMOTE_USER="root"
REMOTE_DIR="/opt/config/"
ARCHIVE_NAME="sync_$(date +%Y%m%d_%H%M%S).tar.gz"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

if [ -z "$REMOTE_HOST" ]; then
    echo -e "${RED}Usage: $0 <printer_ip>${NC}"
    exit 1
fi

cleanup() {
    rm "./${ARCHIVE_NAME}"
}

abort() {
    trap SIGINT
    echo; echo 'Aborted'
    cleanup
    
    exit 2
}

echo -e "${BLUE}Creating archive...${NC}"
tar --exclude="./${ARCHIVE_NAME}" \
--exclude='.git' \
--exclude='.vscode' \
--exclude='./sync*.tar.gz' \
--disable-copyfile \
-czf "${ARCHIVE_NAME}" .

trap "abort" INT

echo -e "${BLUE}Uploading archive to ${REMOTE_HOST}...${NC}"
scp -O "./${ARCHIVE_NAME}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}"

if [ $? -ne 0 ]; then
    echo -e "\n${RED}Unable to upload sync archive to the printer at ${REMOTE_HOST}.${NC}"
    echo "Make sure you have added identity to the printer:"
    echo "ssh-copy-id -i \"/path/to/ssh_key.pub\" root@${REMOTE_HOST}"
    
    cleanup
    exit 2
fi

ssh "${REMOTE_USER}@${REMOTE_HOST}" bash -l << EOF
    ##############################################

    cleanup() {
        rm ./sync_*.tar*
        rm -r "./.sync"
    }

    print_status() {
        local name="\$1"; local status="\$2"; local color="\$3"
        echo -e "${NC}► \${name}\t\t\${color}\${status}${NC}"
    }

    run_service() {
        if [ "\$#" -lt 4 ]; then echo Missing required arguments; exit 3; fi

        local name="\$1"; local status="\$2"; local check_pid="\$3"
        if [ "\$check_pid" -eq 1 ]; then
            if [ "\$#" -lt 6 ]; then echo Missing required arguments; exit 3; fi
            local pid_path="\$4"; local invert="\$5"
            shift 5; local command=("\$@")
        else
            shift 3; local command=("\$@")
        fi

        print_status "\$name" "\${status}..." "${YELLOW}"

        \${command[@]} > /dev/null 2>&1
        local ret=\$?

        if [ "\$ret" -ne 0 ]; then
            print_status "\$name" "Failed" "${RED}"
            exit 2
        fi

        if [ "\$check_pid" -eq 0 ]; then
            print_status "\$name" "Done" "${GREEN}"
            return
        fi

        local pid=\$(cat "\$pid_path")
        for i in \$(seq 0 15); do
            kill -0 "\$pid" > /dev/null 2>&1; local ret=\$?
            if [ \$((ret == 0 ? !invert : invert)) -eq 1 ]; then
                print_status "\$name" "Done" "${GREEN}"
                return
            fi
            sleep 1
        done

        print_status "\$name" "Timeout" "${RED}"
        exit 2
    }


    ##############################################

    cd "${REMOTE_DIR}" || exit 1

    rm -rf "./.sync"
    mkdir "./.sync"

    echo -e "${BLUE}Extracting archive...${NC}"

    gzip -d "./${ARCHIVE_NAME}"
    tar -xf "./${ARCHIVE_NAME%.*}" -C "./.sync/"

    if [ \$? -ne 0 ]; then
        echo -e "${RED}Failed to extract sync archive${NC}"
        cleanup
        exit 1
    fi

    echo -e "${BLUE}Comparing files...${NC}"

    CHANGED=0

    while read -r file; do
        SRC_FILE="\$file"
        DEST_FILE="./mod/\${file#./.sync/}"

        if ! cmp -s "\$SRC_FILE" "\$DEST_FILE"; then
            echo -e "${YELLOW}► File changed: \$DEST_FILE${NC}"
            mkdir -p "\${DEST_FILE%/*}" && cp "\$SRC_FILE" "\$DEST_FILE"
            CHANGED=1
        fi
    done < <(find ./.sync -type f)

    cleanup

    if [ "$SKIP_RESTART" -eq 1 ]; then exit 0; fi

    if [ "\$CHANGED" -eq 1 ]; then
        echo; echo -e "${GREEN}Restarting services...${NC}"; echo

        run_service "Moonraker" "Stopping"      1 \
            "/data/.mod/.zmod/run/moonraker.pid"    1   /etc/init.d/S99moon stop

        run_service "Database"  "Migrating"     0   /opt/config/mod/.shell/migrate_db.sh
        run_service "Moonraker" "Starting"      0   /etc/init.d/S99moon up
        run_service "Klipper"   "Restarting"    0   /opt/config/mod/.shell/restart_klipper.sh

        echo; echo -e "${GREEN}All done!${NC}"
    else
        echo; echo -e "${YELLOW}Printer is already in-sync${NC}"
    fi
EOF

ret=$?

cleanup

if [ "$ret" -ne 0 ]; then
    echo -e "\n${RED}Unable to sync files to the printer at ${REMOTE_HOST}.${NC}"
    exit 2
fi

echo; echo -e "${GREEN}Sync complete!${NC}"
