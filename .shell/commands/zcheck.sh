#!/bin/bash

## Printer file checksum verification
##
## Thanks Sergei Rozhkov <https://github.com/ghzserg>
## For collecting the checksum of firmware files
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license


source /opt/config/mod/.shell/common.sh

ARCHIVE_NAME="md5sum.tar.gz"

unpack() {
    local file_path=$1
    
    mkdir -p "$file_path"
    rm -f "$file_path"/md5sum*
    
    cp /opt/config/mod/${ARCHIVE_NAME} "$file_path"
    gzip -d "$file_path/${ARCHIVE_NAME}"
    tar -xf "$file_path/${ARCHIVE_NAME%.*}" -C "$file_path/"
}

verify() {
    if [ ! -f /opt/config/mod/${ARCHIVE_NAME} ]; then
        echo "@@ Checksum list file is missing!"
        exit 1
    fi
    
    echo "// Extracting files..."
    
    unpack "/data/.tmp"
    cd /data/.tmp || ( echo "Unable to create temp folder."; exit 2 )
    
    echo "// Scanning files for corruption. It might take a while..."
    
    counter=0
    total=$(wc -l < "./md5sum.list")
    while IFS=' ' read -r expected_checksum file_path; do
        full_path="/${file_path#./}"
        
        if [[ ! -f "$full_path" ]]; then
            echo "@@ File $full_path missing."
            continue
        fi
        
        actual_checksum=$(md5sum "$full_path" | awk '{print $1}')
        
        if [[ "$expected_checksum" == "$actual_checksum" ]]; then
            if [ "$1" == "--verbose" ]; then echo "Checksum OK: $full_path"; fi
        else
            echo "@@ Checksum FAILED: $full_path"
        fi
        
        counter=$((counter+1))
        if [ "$((counter % 100))" -eq "0" ]; then
            echo "// Processed ${counter} / ${total}..."
        fi
    done < "./md5sum.list"
    
    rm -f ./md5sum*
    echo "// Done!"
}

tar_archive() {
    echo "// Collecting files. It might take a while..."
    
    unpack "/data/.tmp"
    cd /
    
    (awk '{$1="";$0}sub(FS,"")' < /data/.tmp/md5sum.list) > /data/.tmp/tar_file.list
    
    fname="system_$(date +'%Y%m%d_%H%M%S').tar"
    fpath="/data/.tmp/${fname}"
    tar -chf "$fpath" -T /data/.tmp/tar_file.list &
    pid=$!
    
    abort_handler() {
        trap SIGINT
        echo "?? Aborted"
        
        kill "$pid"
        rm -f "$fpath"
        
        exit 1
    }
    
    trap "abort_handler" INT
    
    while kill -0 $pid; do
        size=$(du -h "$fpath" 2> /dev/null | awk '{print $1}')
        if [ -n "$size" ]; then echo "Written: $size..."; fi
        sleep 1
    done
    
    mv "$fpath" /data/
    echo "// Done! Download the file from \"/data/${fname}\""
}

if [ "$1" == "verify" ]; then
    mv /data/logFiles/verification.log.2 /data/logFiles/verification.log.3  2> /dev/null
    mv /data/logFiles/verification.log.1 /data/logFiles/verification.log.2  2> /dev/null
    mv /data/logFiles/verification.log /data/logFiles/verification.log.1    2> /dev/null
    
    verify "$2" | logged /data/logFiles/verification.log --send-to-screen --screen-level 0 --screen-no-followup
elif [ "$1" == "tar" ]; then
    tar_archive | logged --no-log --send-to-screen --screen-level 0 --screen-no-followup
else
    echo "Unsupported mode: \"$1\""
    echo "Usage: $0 (verify|tar)"
    exit 1
fi
