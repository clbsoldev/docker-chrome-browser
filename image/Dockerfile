# TODO: pin by digest — run `docker buildx imagetools inspect debian:13-slim`
# and paste the *manifest list* digest here (see docker-image-template Readme —
# not `docker inspect`, that only reflects the local host's architecture).
FROM debian:13-slim

ENV DEBIAN_FRONTEND=noninteractive

# TigerVNC (Xtigervnc = X server + real RFB VNC in one, no separate x11vnc needed)
# tigervnc-tools provides tigervncpasswd (moved out of tigervnc-common in trixie)
# Openbox as minimal WM (window decorations only, no full desktop environment)
# gosu for clean privilege drop (root -> browser user) in the entrypoint
# libnss3-tools for the Chrome NSS CA import (certutil)
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        tigervnc-standalone-server \
        tigervnc-common \
        tigervnc-tools \
        openbox \
        dbus-x11 \
        fonts-liberation \
        fonts-noto-color-emoji \
        libnss3-tools \
        xdg-utils \
        gosu \
    && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
        | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY openbox-autostart /etc/xdg/openbox/autostart
RUN chmod +x /usr/local/bin/entrypoint.sh /etc/xdg/openbox/autostart

ENV DISPLAY=:1 \
    VNC_RESOLUTION=1920x1080 \
    VNC_DEPTH=24 \
    PUID=1000 \
    PGID=1000 \
    HOME=/home/browser

EXPOSE 5901

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
