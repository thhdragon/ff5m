#!/bin/sh

export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/opt/bin:/opt/sbin"
export SHELL="$(which zsh)"

if [ -n "$SSH_TTY" ] && [ -z "$ZSH_VERSION" ]; then
    exec "$SHELL" -l
fi