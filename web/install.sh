#!/bin/bash
#
HERE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TOP=$(dirname "${HERE}")

export DEBIAN_FRONTEND=noninteractive

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

for ngc in nginx/*
do
  cfg=$(basename ${ngc})
  [ -f /etc/nginx/${cfg} ] || sudo cp ${ngc} /etc/nginx/${cfg}
done

sudo systemctl --quiet restart nginx

# Install dependencies and tools
sudo apt install fail2ban python3-psycopg2 \
                 nginx certbot python3-certbot-nginx -q -y

sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 > /dev/null 2>&1
sudo mkdir -p /var/lib/letsencrypt/.well-known
sudo chgrp www-data /var/lib/letsencrypt
sudo chmod g+s /var/lib/letsencrypt
sudo systemctl --quiet restart nginx
# We are using a wildcard certificate for now
# Let's Encrypt tries to perform a challenge but fails due to our firewall
sudo certbot certonly --agree-tos --email ron.record@hornblower.com \
             --webroot -w /var/lib/letsencrypt/ -d kasm01.hornblower.com
sudo systemctl --quiet reload nginx

echo "# Restart nginx when certificate is renewed" > /tmp/cli$$
echo "deploy-hook = systemctl reload nginx" >> /tmp/cli$$
if [ -f /etc/letsencrypt/cli.ini ]; then
  grep "deploy-hook" /etc/letsencrypt/cli.ini > /dev/null || {
    sudo cat /etc/letsencrypt/cli.ini /tmp/cli$$ > /tmp/lcl$$
    sudo cp /tmp/lcl$$ /etc/letsencrypt/cli.ini
  }
else
  sudo cp /tmp/cli$$ /etc/letsencrypt/cli.ini
fi
rm -f /tmp/cli$$

[ -f /etc/fail2ban/filter.d/send.conf ] || {
  [ -d /etc/fail2ban/filter.d ] || sudo mkdir -p /etc/fail2ban/filter.d
  sudo cp f2b-send.conf /etc/fail2ban/filter.d/send.conf
}
[ -f /etc/fail2ban/jail.d/jail.local ] || {
  [ -d /etc/fail2ban/jail.d ] || sudo mkdir -p /etc/fail2ban/jail.d
  sudo cp f2b-send.local /etc/fail2ban/jail.d/jail.local
}

sudo systemctl --quiet daemon-reload
sudo systemctl --quiet enable --now nginx
