#!/bin/bash
#
# Update version

FIRMWARE_VERSION="$1"
MOD_VERSION="$2"
PATCH_VERSION="$3"

if [ -z "${FIRMWARE_VERSION}" ] || [ -z "${MOD_VERSION}" ] || [ -z "${PATCH_VERSION}" ]; then
    echo "Error: Missing required argument(s)!"
    echo "Usage: $0 <firmware_version> <mod_version> <patch_version>"
    exit 1
fi

OS_RELEASE_FILE="/etc/os-release"

cp "$OS_RELEASE_FILE" "${OS_RELEASE_FILE}.bak"

update_var() {
    local key="$1"
    local value="$2"
    if grep -q "^$key=" "$OS_RELEASE_FILE"; then
        sed -i "s|^$key=.*|$key=\"$value\"|" "$OS_RELEASE_FILE"
    else
        echo "$key=\"$value\"" >> "$OS_RELEASE_FILE"
    fi
}


update_var "NAME" "zmod-lite"
update_var "VERSION" "${MOD_VERSION}"
update_var "VERSION_ID" "${MOD_VERSION}-${PATCH_VERSION}"
update_var "PRETTY_NAME" "zmod-lite ${MOD_VERSION}"
update_var "VERSION_CODENAME" "FF5M ${FIRMWARE_VERSION} / ${MOD_VERSION}-${PATCH_VERSION}"

echo "The os-release file has been updated."
