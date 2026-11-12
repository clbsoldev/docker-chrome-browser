#!/bin/bash
set -e

CA_DIR="/usr/local/share/ca-certificates"
VNC_PASSWD_FILE="/home/browser/.vnc/passwd"
INSECURE_DEFAULT_VNC_PASSWORD="Start123!"

if ! getent group "${PGID}" >/dev/null; then
    groupadd -g "${PGID}" browser
fi
if ! id -u browser >/dev/null 2>&1; then
    useradd -m -u "${PUID}" -g "${PGID}" -s /bin/bash browser
fi
chown -R "${PUID}:${PGID}" /home/browser

mkdir -p /home/browser/.vnc
chown -R "${PUID}:${PGID}" /home/browser/.vnc

if compgen -G "${CA_DIR}/*.crt" > /dev/null; then
    echo "[entrypoint] custom CA certificate(s) found under ${CA_DIR} - importing into system trust store and Chrome NSS trust"
    update-ca-certificates
    mkdir -p /home/browser/.pki/nssdb
    gosu browser certutil -d sql:/home/browser/.pki/nssdb -N --empty-password 2>/dev/null || true
    for cert in "${CA_DIR}"/*.crt; do
        cert_name="$(basename "${cert}" .crt)"
        gosu browser certutil -d sql:/home/browser/.pki/nssdb -D -n "${cert_name}" 2>/dev/null || true
        gosu browser certutil -d sql:/home/browser/.pki/nssdb -A -t "C,," -n "${cert_name}" -i "${cert}"
    done
else
    echo "[entrypoint] no custom CA certificates found under ${CA_DIR} - skipping trust import (PKI not deployed yet)"
fi

if [ -n "${VNC_PASSWORD_FILE}" ] && [ -f "${VNC_PASSWORD_FILE}" ]; then
    gosu browser bash -c "tigervncpasswd -f < '${VNC_PASSWORD_FILE}' > '${VNC_PASSWD_FILE}'"
    chmod 600 "${VNC_PASSWD_FILE}"
elif [ -n "${VNC_PASSWORD}" ] && [ ! -f "${VNC_PASSWD_FILE}" ]; then
    gosu browser bash -c "echo '${VNC_PASSWORD}' | tigervncpasswd -f > ${VNC_PASSWD_FILE}"
    chmod 600 "${VNC_PASSWD_FILE}"
elif [ ! -f "${VNC_PASSWD_FILE}" ]; then
    echo "##############################################################"
    echo "# WARNING: no VNC_PASSWORD_FILE or VNC_PASSWORD set!"
    echo "# Falling back to an INSECURE default VNC password."
    echo "# Set VNC_PASSWORD_FILE (preferred) or VNC_PASSWORD before"
    echo "# exposing this anywhere beyond local testing."
    echo "##############################################################"
    gosu browser bash -c "echo '${INSECURE_DEFAULT_VNC_PASSWORD}' | tigervncpasswd -f > ${VNC_PASSWD_FILE}"
    chmod 600 "${VNC_PASSWD_FILE}"
fi

SEC_ARGS="-SecurityTypes VncAuth -PasswordFile ${VNC_PASSWD_FILE}"

# shellcheck disable=SC2086
gosu browser Xtigervnc "${DISPLAY}" \
    -geometry "${VNC_RESOLUTION}" \
    -depth "${VNC_DEPTH}" \
    ${SEC_ARGS} \
    -localhost=0 &
XVNC_PID=$!

sleep 2

gosu browser bash -c "export DISPLAY=${DISPLAY}; export HOME=/home/browser; dbus-launch --exit-with-session openbox-session" &
WM_PID=$!

term_handler() {
    kill -TERM "${WM_PID}" "${XVNC_PID}" 2>/dev/null || true
    wait
}
trap term_handler SIGTERM SIGINT

wait -n "${XVNC_PID}" "${WM_PID}"
