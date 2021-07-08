# References:
#   https://gist.github.com/demaniak/c56531c8d673a6f58ee54b5621796548
#   https://github.com/mdouchement/docker-zoom-us
#   https://hub.docker.com/r/solarce/zoom-us
#   https://github.com/sameersbn/docker-skype
FROM debian:buster
MAINTAINER olberger

ENV DEBIAN_FRONTEND noninteractive

# Refresh package lists
RUN apt-get update
RUN apt-get -qy dist-upgrade

# Dependencies for the client .deb

RUN apt-get install -qy curl locales sudo pulseaudio apt-utils apt-transport-https libgbm1 \
    libatk-bridge2.0-0 libcups2 libgtk-3-0 libnspr4 libnss3 libxss1 gpg libsecret-1-0

ENV TZ Pacific/Tahiti

COPY ./environment /etc/environment
COPY ./locale.gen /etc/locale.gen

RUN echo "$TZ" > /etc/timezone \
    && rm -f /etc/localtime \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && locale-gen fr_FR.UTF-8 \
    && dpkg-reconfigure locales

ENV LANG fr_FR:UTF-8
ENV LANGUAGE fr
ENV LC_CTYPE fr_FR.utf8
ENV LC_MESSAGES fr_FR.utf8
ENV LC_ALL fr_FR.utf8

ARG TEAMS_URL="https://go.microsoft.com/fwlink/p/?LinkID=2112886&clcid=0x40c&culture=fr-fr&country=FR"

# Grab the client .deb
# Install the client .deb
# Cleanup
RUN curl -sSL $TEAMS_URL -o /tmp/teams.deb
RUN dpkg -i /tmp/teams.deb
RUN apt-get -f install

COPY scripts/ /var/cache/teams/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
