ARG BASE_TAG="1.14.0"
FROM kasmweb/ubuntu-focal-desktop:$BASE_TAG
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

# Install Tailscale

RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg |  apt-key add -
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list |  tee -a /etc/apt/sources.list.d/tailscale.list
RUN apt-get update && \
apt-get install -y tailscale
apt-get install -y build-essential autotools-dev autoconf libtool cmake flex bison \
        pkg-config libncurses-dev coreutils git make tar zstd make g++ \
        libjpeg-dev libpng-dev libssl-dev libncursesw5-dev gcc-10 \
        g++-10 cpp-10 xfce4-goodies

# Sudo is not strictly necessary when using docker exec to start tailscale
# but will be needed to start tailscale manually
RUN apt-get update \
&& apt-get install -y sudo \
&& echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
&& rm -rf /var/lib/apt/list/*

######### End Customizations ###########

RUN chown 1000:0 $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
