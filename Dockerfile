FROM alpine:edge

RUN apk -U upgrade -a && apk --no-cache update && echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

# Install packages for PDF Printing from Firefox
RUN apk --no-cache add \
    gutenprint-cups \
    cups-pdf \
    cups-client \
    fontconfig \
    firefox-esr \
    imagemagick \
    xdotool \
    xvfb \
    xvfb-run \
    bash \
    dbus \
    fontconfig \
    ttf-freefont \
    tar \
    gzip

# Copy in fonts
RUN mkdir -p /usr/share/fonts
COPY resources/fonts.tar.gz /usr/share/fonts
RUN cd /usr/share/fonts && tar -zxf fonts.tar.gz && rm fonts.tar.gz
RUN fc-cache -f && rm -rf /var/cache/*

# Copy in base firefox profile
RUN mkdir -p /app/firefox/base
COPY config/firefox/base_profile /app/firefox/base

# Copy in bash scripts to do the printing
RUN mkdir -p /app/bin
COPY bin /app/bin

ENV TZ=America/Toronto
ENV DEV=0
ENV URL="https://github.com/"

ENV PROXY_USER=""
ENV PROXY_PASS=""
ENV PROXY_HOST=""
ENV SSL=0

VOLUME /output
WORKDIR /output

ENTRYPOINT ["/app/bin/entry-point.sh"]
