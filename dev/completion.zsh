HEROKU_AC_ZSH_SETUP_PATH="${HOME}/Library/Caches/heroku/autocomplete/zsh_setup" && test -f $HEROKU_AC_ZSH_SETUP_PATH && source $HEROKU_AC_ZSH_SETUP_PATH;export PATH="/usr/local/opt/node@8/bin:$PATH"
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/packer packer

