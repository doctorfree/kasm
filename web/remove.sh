#!/bin/bash
#
HERE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TOP=$(dirname "${HERE}")

export DEBIAN_FRONTEND=noninteractive

# Remove dependencies and tools
sudo apt remove apache2 fail2ban python3-psycopg2 \
                nginx certbot python3-certbot-nginx -q -y
sudo apt autoremove -q -y

sudo rm -rf /etc/nginx /etc/letsencrypt /etc/apache2 \
	    /etc/guacamole /opt/tomcat
