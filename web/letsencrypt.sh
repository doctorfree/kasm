#!/bin/bash
#
sudo certbot certonly --agree-tos --email ronaldrecord@gmail.com \
                      --manual -w /var/lib/letsencrypt/ \
                      -d kasm01.hornblower.com
