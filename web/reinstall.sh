#!/bin/bash
#
HERE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TOP=$(dirname "${HERE}")

export DEBIAN_FRONTEND=noninteractive

sudo systemctl stop nginx

# Install dependencies and tools
sudo apt remove nginx -q -y
sudo apt autoremove -q -y
sudo apt install nginx -q -y

[ -d /etc/nginx/sites-available ] || sudo mkdir -p /etc/nginx/sites-available
[ -f kasm01.hornblower.com ] && {
    sudo cp kasm01.hornblower.com /etc/nginx/sites-available
    sudo rm -f /etc/nginx/sites-enabled/kasm01.hornblower.com
    sudo ln -s /etc/nginx/sites-available/kasm01.hornblower.com \
               /etc/nginx/sites-enabled/kasm01.hornblower.com
    sudo rm -f /etc/nginx/sites-enabled/default
}
[ -d /etc/nginx/ssl ] || sudo mkdir -p /etc/nginx/ssl
[ -f ${TOP}/certs/wildcard/server.crt ] && {
    sudo cp ${TOP}/certs/wildcard/server.crt /etc/nginx/ssl
    sudo chmod 444 /etc/nginx/ssl/server.crt
}
[ -f ${TOP}/certs/wildcard/server.key ] && {
    sudo cp ${TOP}/certs/wildcard/server.key /etc/nginx/ssl
    sudo chown root /etc/nginx/ssl/server.key
    sudo chmod 400 /etc/nginx/ssl/server.key
}
[ -d /etc/nginx/snippets ] || sudo mkdir -p /etc/nginx/snippets
[ -f letsencrypt.conf ] && sudo cp letsencrypt.conf /etc/nginx/snippets
[ -f ssl.conf ] && sudo cp ssl.conf /etc/nginx/snippets

sudo systemctl daemon-reload
sudo systemctl enable --now nginx
sudo systemctl start nginx
