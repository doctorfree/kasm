#! /bin/sh

# create tun device
if [ ! -c /dev/net/tun ]; then
  mkdir -p /dev/net
  mknod /dev/net/tun c 10 200
fi

# Enable devices MASQUERADE mode
iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE
iptables -t nat -A POSTROUTING -o tailscale+ -j MASQUERADE

# start vpn client
tailscaled
