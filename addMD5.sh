#!/bin/bash

##
## Adding MD5 checkum to gcode file
##
## Copyright (C) 2025 Alexander K <https://github.com/drA1ex>
## Copyright (C) 2025 Sergei Rozhkov <https://github.com/ghzserg>
##
## This file may be distributed under the terms of the GNU GPLv3 license

if [ $# -ne 1 ]; then echo "Usage: ./$0 your_file.gcode"; exit 1; fi
if ! [ -f $1 ]; then echo "File $1 not found"; exit 1; fi

# Calculate the MD5 hash of the file
md5=$(md5sum "$1" | awk '{print $1}')

# Define prefix
prefix="; MD5:"

# Construct the payload
payload="${prefix}${md5}"

# Create a temporary file and append the original file content
tempfile=$(mktemp)
echo "$payload" > "$tempfile"
cat "$1" >> "$tempfile"

# Move the temp file to the original file location
mv "$tempfile" "$1"
