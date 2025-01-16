export SHELL=`which zsh`

if [ -n "$SSH_TTY" ] && [ -z "$ZSH_VERSION" ]; then
    exec "$SHELL" -l
fi