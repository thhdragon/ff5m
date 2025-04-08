#!/bin/bash

## Script to initialize Forge-X OTA
##
## Copyright (C) 2025, Alexander K <https://github.com/drA1ex>
##
## This file may be distributed under the terms of the GNU GPLv3 license

GIT_BRANCH=$(git --git-dir=/opt/config/mod/.git rev-parse --abbrev-ref HEAD)
GIT_COMMIT_FULL=$(git --git-dir=/opt/config/mod/.git rev-parse HEAD)

if [ -z "$GIT_BRANCH" ] || [ -z "$GIT_COMMIT_FULL" ]; then
    echo "@@ Unable to collect git metadata"
    exit 1
fi

VERSION=$(cat /opt/config/mod/version.txt)
GIT_VERSION="$VERSION-usb"

sqlite3 /opt/config/mod_data/database/moonraker-sql.db << EOF
INSERT OR REPLACE INTO "namespace_store" ("namespace", "key", "value") VALUES ('update_manager', 'forge-x', '{
    "branches": [ "$GIT_BRANCH" ],
    "cbh_count": 0,
    "commits_behind": [],
    "corrupt": false,
    "current_commit": "$GIT_COMMIT_FULL",
    "current_version": "$GIT_VERSION",
    "diverged": false,
    "git_branch": "$GIT_BRANCH",
    "git_messages":
    [],
    "git_owner": "DrA1ex",
    "git_remote": "origin",
    "git_repo_name": "ff5m",
    "head_detached": false,
    "is_valid": true,
    "last_config_hash": "***skip***",
    "last_refresh_time": 0,
    "modified_files":
    [],
    "pinned_commit_valid": true,
    "pip_version":
    [],
    "recovery_url": "https://github.com/DrA1ex/ff5m.git",
    "repo_valid": true,
    "rollback_branch": "$GIT_BRANCH",
    "rollback_commit": "$GIT_COMMIT_FULL",
    "rollback_version": "$GIT_VERSION",
    "untracked_files":
    [],
    "upstream_commit": "$GIT_COMMIT_FULL",
    "upstream_url": "https://github.com/DrA1ex/ff5m.git",
    "upstream_version": "$GIT_VERSION"
}');
EOF

exit $?
