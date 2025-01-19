#!/bin/bash

## Runs script with printer's firmware env
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

load_env() {
    local env_file="$1"
    
    if [ ! -f "$env_file" ]; then
        echo "Environment file not found: $env_file"
        return 1
    fi

    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^\s*\# ]] || [[ -z "$line" ]] && continue
        
        # Match parameter definition
        if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(.*)$ ]]; then
            name="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"

            # Handle substitution like %(VAR)s
            while [[ "$value" =~ %\(([^\)]+)\)s ]]; do
                var_name="${BASH_REMATCH[1]}"
                value="${value//%($var_name)s/${!var_name}}"
            done
            
            # Handle substitution like %VAR%
            while [[ "$value" =~ %([^%]+)% ]]; do
                var_name="${BASH_REMATCH[1]}"
                value="${value//%$var_name%/${!var_name}}"
            done

            eval "export $name=$value"
        fi
    done < "$env_file"
}

load_env "$1"
shift

# Run the provided command
"$@"
