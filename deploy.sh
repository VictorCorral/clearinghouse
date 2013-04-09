#!/bin/bash
# Copies files to the server and runs install.

#host="${1:-map7@192.168.200.161}"
host="${1}"
json="${2}"

if [ -z "$host" ]; then
    echo "Usage: ./deploy.sh [user@host] [json]"
	echo 
    echo "EG: ./deploy.sh fred@192.168.1.1 web_server.json"
    echo "If no json is given it will default to solo.json"
    exit
fi

if [ -z "$json" ]; then
    json="webserver.json"
fi

# The host key might change when we instantiate a new VM, so
# we remove (-R) the old host key from known_hosts
echo 'keygen'
ssh-keygen -R "${host#*@}" 2> /dev/null

echo 'copy chef dir & run install.sh'
tar cj . | ssh -o 'StrictHostKeyChecking no' "$host" "
sudo rm -rf ~/chef &&
mkdir ~/chef &&
cd ~/chef &&
tar xj &&
sudo bash install.sh $json"
