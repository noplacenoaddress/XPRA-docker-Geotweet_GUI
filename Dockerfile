FROM ubuntu:16.04

MAINTAINER No Place No Address <npna@protonmail.ch>

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:100

# Expose the SSH port
EXPOSE 22
EXPOSE 2022

RUN apt-get update && apt-get -y install apt-utils

RUN apt-get -y upgrade

RUN apt-get install -y curl \
    && curl https://winswitch.org/gpg.asc | apt-key add - \
    && echo "deb http://winswitch.org/ xenial main" > /etc/apt/sources.list.d/winswitch.list 

RUN apt-get update

RUN apt-get -y install openssh-server \
    x11-apps xterm language-pack-en-base \
    git sudo nano xpra \
    build-essential


# Create OpenSSH privilege separation directory
RUN mkdir /var/run/sshd 

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

USER docker
WORKDIR /home/docker
RUN mkdir /home/docker/.ssh/
RUN git clone https://github.com/Pinperepette/Geotweet_GUI.git

USER root
WORKDIR /home/docker/Geotweet_GUI
RUN apt-get -y install python-geopy python-tweepy python-simplejson \
	python-httplib2 python-six python-qt-binding python-qt-binding \
	python-qt4-dbus python-qt4-dev python-qt4-gl
RUN dpkg -i *.deb
RUN chmod +x /usr/share/geotweet/Geotweet.py

VOLUME /home/docker

ADD xpra-display /tmp/xpra-display
RUN echo "$(cat /tmp/xpra-display)\n$(cat /etc/bash.bashrc)" > /etc/bash.bashrc 

ADD geotweet /tmp/geotweet
RUN mv /tmp/geotweet /usr/bin
RUN chmod +x /usr/bin/geotweet

# Start SSH anx Xpra
CMD chown -R docker:docker /home/docker && /usr/sbin/sshd && rm -f /tmp/.X100-lock && su docker -c "xpra start $DISPLAY --mdns=no --webcam=no --notifications=no && sleep 1 && cp ~/.xpra/run-xpra /tmp/run-xpra && cat /tmp/run-xpra | grep -v affinity > ~/.xpra/run-xpra && sleep infinity"
