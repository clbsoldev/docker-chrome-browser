#!/usr/bin/env python3
"""image/monitor.py
Optional monitoring endpoint - enabled via MONITORING=1 (or "true").
Serves container uptime and per-process status as JSON.

Watched process names come from WATCHED_SERVICES (comma-separated env var),
so this script is unchanged across different docker_stack images - only
the env var differs per container.
"""

import json
import os
import subprocess
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

START_TIME = time.time()
HOST_NAME = os.uname().nodename
MONITOR_PORT = int(os.environ.get("MONITOR_PORT", "8081"))
WATCHED_SERVICES = [
    s.strip() for s in os.environ.get("WATCHED_SERVICES", "").split(",") if s.strip()
]


def is_running(process_name):
    result = subprocess.run(
        ["pgrep", "-x", process_name],
        capture_output=True,
        timeout=5,
    )
    return result.returncode == 0


class MonitorHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        if self.path not in ("/", "/index.json"):
            self.send_response(404)
            self.end_headers()
            return

        try:
            data = {
                "hostname": HOST_NAME,
                "uptime_seconds": round(time.time() - START_TIME),
                "services": {name: is_running(name) for name in WATCHED_SERVICES},
            }
            status = 200
        except Exception as e:
            data = {"error": str(e)}
            status = 500

        body = json.dumps(data, indent=2).encode()
        self.send_response(status)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    if not WATCHED_SERVICES:
        print("[monitor] WARNING: WATCHED_SERVICES is empty - no processes will be checked")
    server = HTTPServer(("0.0.0.0", MONITOR_PORT), MonitorHandler)
    print(f"Monitoring endpoint on :{MONITOR_PORT} (hostname={HOST_NAME}, watching={WATCHED_SERVICES})")
    server.serve_forever()
