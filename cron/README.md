# Kasm crontab

The files in this directory are intended to serve as a guideline for
`cron` jobs on a Kasm server. These scripts can be used to periodically
clean dangling volumes/images and bloated docker log files.

## Table of contents

- [Setup](#setup)
- [Cron](#cron)
- [Dangling volumes and images](#dangling-volumes-and-images)
- [Docker logs](#docker-logs)
- [Letsencrypt certs](#letsencrypt-certs)

## Setup

The `cron` jobs should be run as rooot. To setup these `cron` jobs,
copy the scripts to `/root/` on the Kasm server and add `crontab`
entries for the root user:

```bash
sudo cp clean_dangling_docker /root
sudo cp clean_docker_logs /root
# If using Letsencrypt to renew certs, periodically copy in the new certificate
sudo cp inst_cert /root
# Modify crontab.in to include any other jobs
# Comment out the Letsencrypt renewal `inst_cert` if not using Letsencrypt
sudo crontab crontab.in
```

## Cron

```
15 0 * *   1 /root/clean_dangling_docker > /dev/null 2>&1
0  0 1 *   * /root/clean_docker_logs > /dev/null 2>&1
0  0 1 */2 * /root/inst_cert > /dev/null 2>&1
```

## Dangling volumes and images

```bash
iamroot=
if [ "${EUID}" ]; then
  [ ${EUID} -eq 0 ] && iamroot=1
else
  uid=$(id -u)
  [ ${uid} -eq 0 ] && iamroot=1
fi

[ "${iamroot}" ] || {
  echo "Must be run as root. Exiting."
  exit 1
}

dangimg=$(docker images -q -f dangling=true)
[ "${dangimg}" ] && {
  docker rmi $(docker images -q -f dangling=true)
}
dangvol=$(docker volume ls -qf dangling=true)
[ "${dangvol}" ] && {
  docker volume rm $(docker volume ls -qf dangling=true)
}
```

## Docker logs

```bash
iamroot=
if [ "${EUID}" ]; then
  [ ${EUID} -eq 0 ] && iamroot=1
else
  uid=$(id -u)
  [ ${uid} -eq 0 ] && iamroot=1
fi

[ "${iamroot}" ] || {
  echo "Must be run as root. Exiting."
  exit 1
}

docker container list | awk ' { print $NF } ' | grep -v NAMES | \
while read container_name
do
  path=$(docker container inspect ${container_name} --format "{{ .LogPath }}")
  size=$(/bin/ls -s ${path} | awk '{ print $1 }')
  [ "${size}" ] || continue
  [ ${size} -gt 250000 ] && echo "" > ${path}
done
```

## Letsencrypt certs

```bash
LIVE="/etc/letsencrypt/live/neoman.dev"
DOMAIN="YOUR.DOMAIN"
DEST="/opt/kasm/current/certs"

# Check for Letsencrypt files
[ -f ${LIVE}/${DOMAIN}/fullchain.pem ] || exit 1
[ -f ${LIVE}/${DOMAIN}/privkey.pem ] || exit 1

# Stop Kasm
/opt/kasm/bin/stop

cp ${LIVE}/${DOMAIN}/fullchain.pem ${DEST}/kasm_nginx.crt
cp ${LIVE}/${DOMAIN}/privkey.pem ${DEST}/kasm_nginx.key

# Start Kasm
/opt/kasm/bin/start
```
