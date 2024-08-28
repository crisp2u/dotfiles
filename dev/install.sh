#!/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


#TODO setup docker memory
#/Users/<username>/Library/Group\ Containers/group.com.docker/settings.json
#sed -i .bak 's/2048/10240/g' /Users/`id -un`/Library/Group\ Containers/group.com.docker/settings.json

$DIR/sublime.sh

curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
installer -pkg AWSCLIV2.pkg -target /
rm AWSCLIV2.pkg