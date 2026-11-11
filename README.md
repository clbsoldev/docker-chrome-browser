# docker-browser-chrome

Minimal Debian + TigerVNC + Google Chrome container for accessing internal
lab web services via VNC (and later Guacamole). Real RFB VNC only — no
HTTP/WebRTC streaming (Selkies/noVNC) — so it works directly with plain VNC
clients and with Guacamole's native VNC protocol.

## Image

- Base: Debian 13 (slim), multi-arch (amd64/arm64)
- `Xvnc` (TigerVNC) + Openbox (minimal window manager) + `google-chrome-stable`
  (official Google packages, amd64 and arm64)
- No multi-user support by design — one container per user

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `VNC_RESOLUTION` | `1920x1080` | Xvnc screen resolution |
| `VNC_DEPTH` | `24` | Color depth |
| `PUID` / `PGID` | `1000` / `1000` | UID/GID for the `browser` user |
| `VNC_PASSWORD_FILE` | — | Path to a file containing the VNC password (preferred) |
| `VNC_PASSWORD` | — | Plaintext VNC password (fallback, testing only) |

If neither is set, the container falls back to an **insecure default
password** (`Start123!`), logged loudly as a warning on startup, so it's
testable out of the box.

## Volumes

| Path | Purpose |
|---|---|
| `/home/browser` | Chrome profile (persist across restarts) |
| `/etc/opt/chrome/policies/managed/bookmarks.json` | Chrome `ManagedBookmarks` enterprise policy |
| `/usr/local/share/ca-certificates/` | Mount custom CA `.crt` files here — picked up automatically on startup |

## Port

`5901/tcp` — VNC (RFB). No HTTP port.
