#!/bin/bash
#
# Synchronize local changes to the printer

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

echo -e "${BLUE}Creating archive...${NC}"
tar --exclude="./${ARCHIVE_NAME}" \
    --exclude='.git' \
    --exclude='.vscode' \
    --exclude='./sync*.tar.gz' \
    --disable-copyfile \
    -czf "${ARCHIVE_NAME}" .

echo -e "${BLUE}Uploading archive to ${REMOTE_HOST}...${NC}"
scp -O "./${ARCHIVE_NAME}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}"

if [ $? -ne 0 ]; then
    echo -e "\n${RED} Unable to upload sync archive to the printer at ${REMOTE_HOST}.${NC}"
    echo "Make shure you have added identity to the printer:"
    echo "ssh-copy-id -i \"/path/to/ssh_key.pub\" root@${REMOTE_HOST}"

    cleanup

    exit 2
fi

ssh "${REMOTE_USER}@${REMOTE_HOST}" bash -l << EOF
    cd "${REMOTE_DIR}" || exit 1

    rm -rf "./.sync"
    mkdir "./.sync"

    cleanup() {
        rm ./sync_*.tar*
        rm -r "./.sync"
    }

    echo -e "${BLUE} Extracting archive...${NC}"

    gzip -d "./${ARCHIVE_NAME}"
    tar -xf "./${ARCHIVE_NAME%.*}" -C "./.sync/"

    if [ \$? -ne 0 ]; then
        echo -e "${RED} Failed to extract sync archive${NC}"
        cleanup
        exit 1
    fi

    echo -e "${BLUE} Comparing files...${NC}"

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

        /etc/init.d/S99moon stop > /dev/null

        PID=\$(cat /data/.mod/.zmod/run/moonraker.pid)
        for i in \$(seq 0 15); do
            kill -0 "\$PID" 2>/dev/null || break
            sleep 1
        done
        echo -e "${NC}► Moonraker\t\t${BLUE}Stopped${NC}"

        echo -e "${NC}► Database\t\t${YELLOW}Migrating...${NC}"

        /opt/config/mod/.shell/migrate_db.sh > /dev/null; ret=\$?
        if [ "\$ret" -ne 0 ]; then 
            if [ "\$ret" -gt 1 ]; then echo -e "${NC}► Database\t\t${RED}Migration failed${NC}"; exit 2;  fi

            echo -e "${NC}► Database\t\t${BLUE}Up to date${NC}"
        else
            echo -e "${NC}► Database\t\t${GREEN}Migrated${NC}"
        fi

        echo -e "${NC}► Moonraker\t\t${YELLOW}Starting...${NC}"
        /etc/init.d/S99moon up > /dev/null

        PID=\$(cat /data/.mod/.zmod/run/moonraker.pid)
        kill -0 "\$PID" 2>/dev/null
        if [ "\$?" -ne 0 ]; then echo -e "${NC}► Moonraker\t\t${RED}Failed${NC}"; exit 2; fi

        echo -e "${NC}► Moonraker\t\t${GREEN}Started${NC}"

        echo -e "${NC}► Klipper\t\t${YELLOW}Restarting...${NC}"

        /opt/config/mod/.shell/restart_klipper.sh > /dev/null
        if [ "\$?" -ne 0 ]; then echo -e "${NC}► Klipper\t\t${RED}Failed${NC}"; exit 2; fi
        
        echo -e "${NC}► Klipper\t\t${GREEN}Done${NC}"

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
