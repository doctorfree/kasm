# Kasm Workspaces

[Kasm Workspaces](https://kasmweb.com) provides enterprise-class orchestration,
data loss prevention, and web streaming technology to enable the delivery of
containerized workloads to your browser and desktops to end-users.

This repository contains scripts to build and push custom Kasm docker images.

## Table of Contents

- [Installation](#installation)
  - [Download and extract](#download-and-extract)
  - [To run Kasm on port 8443 with a reverse proxy on 443](#to-run-kasm-on-port-8443-with-a-reverse-proxy-on-443)
  - [Upgrade](#upgrade)
- [Custom Docker Images](#custom-docker-images)
- [Kasm Workspace Registries](#kasm-workspace-registries)
- [References](#references)

## Installation

### Download and extract

The standard single server Kasm installation process, using version 1.15.0 as
and example, can be performed with the following on a system satisfying the
Kasm platform requirements:

```bash
[ -d $HOME/Kasm ] || mkdir -p $HOME/Kasm
cd $HOME/Kasm
curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_1.15.0.06fdc8.tar.gz
tar -xf kasm_release_1.15.0.06fdc8.tar.gz
sudo bash kasm_release/install.sh --accept-eula --swap-size 8192
```

### To run Kasm on port 8443 with a reverse proxy on 443

```bash
sudo bash kasm_release/install.sh -L 8443 --accept-eula --swap-size 8192
```

- Log into the Web Application at https://<WEBAPP_SERVER>
- Default usernames are `admin@kasm.local` and `user@kasm.local`
- Passwords will be randomly generated and presented at the end of the install
  - Unless the `--admin-password` and/or `--user-password` are specified

### Upgrade

The automated upgrade script can be used to upgrade a previous installation to `1.15.0`.

Administrators have several options to choose from when running the automated upgrade script:

| **Flag**                      | **Description** |
| ----------------------------- | --------------- |
| -h|--help                     | Display this help menu |
| -L|--proxy-port               | Default Proxy Listening Port |
| -s|--offline-service          | Path to the tar.gz service images offline installer |
| -S|--role                     | Role to Upgrade: `app|db|agent|remote_db|guac|proxy` |
| -p|--public-hostname | Agent/Component `IP/Hostname` used to register with deployment. |
| -g|--database-master-user     | Database master username required for remote DB |
| -G|--database-master-password | Database master password required for remote DB |
| -q|--db-hostname              | Database Hostname needed when upgrading agent and pulling images |
| -T|--db-port                  | Database port needed when upgrading agent and pulling images (default 5432) |
| -Q|--db-password              | Database Password needed when upgrading agent and pulling images |
| -b|--no-check-disk            | Do not check disk space |
| -n|--api-hostname             | Set API server hostname |
| -A|--enable-lossless          | Enable lossless streaming option (1.12 and above) |
| -O|--use-rolling-images       | Use rolling Service images |
| -k|--registration-token       | Register a component with an existing deployment. |
| --slim-images                 | Use slim alpine based service containers |

In this example `--proxy-port` is used.

```bash
cd /tmp
curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_1.15.0.06fdc8.tar.gz
tar -xf kasm_release_1.15.0.06fdc8.tar.gz
sudo bash kasm_release/upgrade.sh --proxy-port 443
```

## Custom Docker Images

See the Kasm Workspaces documentation on
[Building Custom Images](https://kasmweb.com/docs/latest/how_to/building_images.html#).

Many example custom Kasm image builder Dockerfiles can be found at
https://github.com/doctorfree/workspaces-images including a `osint` image.
Using the `osint` open source intelligence Kasm workspace as an example,
to build the `osint` workspace image:

```bash
# On the Kasm Workspaces server
git clone https://github.com/doctorfree/kasm
cd kasm
export GH_TOKEN="<YOUR-GITHUB-API-TOKEN>"
./bin/build-osint
# With write access to Docker Hub
cd workspaces-images
bin/push-osint
```

After building a custom image, as an administrator in Kasm Workspaces,
add the custom Workspace with `Workspaces -> Workspaces -> Add Workspace`.
Add the `osint` image as:

- **Workspace Type**: `Container`
- **Thumbnail URL**: `https://doctorfree.github.io/kasm-registry/1.0/icons/osint.png`
- **Docker Image**: `doctorwhen/kasm:osint`
- **Cores**: `2`
- **Memory**: `5636`
- **GPU Count**: `0`
- **CPU Allocation Method**: `inherit`
- **Persistent Profile Path**: `/u/kasm_profiles/{image_id}/{user_id}`
- **Docker Run Config Override**: `{ "hostname": "kasm-osint", "ports": { "5001/tcp": 5001 } }`

After adding a Workspace, check `Workspaces -> Registry -> Installed Workspaces`
to verify the Workspace is installed.

## Kasm Workspace Registries

Building, pushing, installing, and configuring Kasm custom images can be greatly
simplified by utilizing a
[Kasm workspace registry](https://www.kasmweb.com/docs/latest/guide/workspace_registry.html).
A 3rd party Kasm workspace registry for several custom Kasm workspace images is
maintained at https://doctorfree.github.io/kasm-registry/1.0/

To utilize this Kasm registry, as a Kasm admin click on `Workspaces -> Registry`
in the Kasm admin web UI. Click on the `Registries` tab and `Add new`. Enter the
workspace registry link, in this example https://doctorfree.github.io/kasm-registry/

Installing Kasm workspaces from a registry enables the use of prebuilt and
preconfigured Kasm workspaces.

**Warning:** You should only install registries from 3rd parties that you trust,
and even then before installing a workspace you should check to see what commands
are being executed. There are a couple of ways this can be done:

- Click on a workspace tile and instead of clicking install, click on edit.
- From the Registry page where you got the Workspace Registry Link, clicking on one of the workspaces takes you to a page that displays all the JSON for that workspace (you can also get to this by clicking the registry logo in the list on registries at the top of the page).

Either of these 2 options allows you to see everything that is being set.
Pay particular attention to anything in the Docker Run Config Override (JSON)
field (run_config in the workspace JSON) or the Docker Exec Config (JSON)
field (exec_config in the workspace JSON) as these fields allow arbitrary
commands to be run. If either of these fields are populated and you are unsure
of what they are doing, ask the 3rd party to clarify before blindly installing.

## References

- [Kasm Documentation](https://www.kasmweb.com/docs/latest/index.html)
- [Kasm Administration](https://www.kasmweb.com/docs/latest/admin_guide.html)
- [Kasm User Guide](https://www.kasmweb.com/docs/latest/user_guide.html)
- [Kasm Workspaces - Resource Allocation](https://youtu.be/lv85XZ8EdjY?si=xcSfB-EWtu-2tIHQ) (YouTube)
- [KasmVNC](https://www.kasmweb.com/kasmvnc)
- [Record Technologies Kasm Registry](https://doctorfree.github.io/kasm-registry/1.0)
  - [Github Repository](https://github.com/doctorfree/kasm-registry) (deployment details)
- [LinuxServer.io](https://www.linuxserver.io)
  - [3rd Party Workspace Registry](https://kasmregistry.linuxserver.io)
  - [Generate Add Workspace JSON](https://kasmregistry.linuxserver.io/1.0/new)
- [Dockerizing a node.js Web Application](https://semaphoreci.com/community/tutorials/dockerizing-a-node-js-web-application)
