#!/usr/bin/env bash
set -euo pipefail

port="${MVER_PREVIEW_PORT:-6080}"
display_number="${MVER_PREVIEW_DISPLAY:-99}"
display=":${display_number}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
binary="${MVER_BINARY:-${root}/build/src/mver}"

for command in Xvfb x11vnc websockify; do
  command -v "${command}" >/dev/null || {
    echo "Missing ${command}. On Ubuntu install: xvfb x11vnc novnc websockify" >&2
    exit 2
  }
done
[[ -x "${binary}" ]] || {
  echo "Missing executable ${binary}; build mver first." >&2
  exit 2
}

novnc_web="${NOVNC_WEB:-/usr/share/novnc}"
[[ -d "${novnc_web}" ]] || {
  echo "No noVNC web root at ${novnc_web}; set NOVNC_WEB explicitly." >&2
  exit 2
}

work="$(mktemp -d)"
cleanup() {
  jobs -pr | xargs -r kill 2>/dev/null || true
  rm -rf "${work}"
}
trap cleanup EXIT INT TERM

Xvfb "${display}" -screen 0 1280x800x24 -nolisten tcp >"${work}/xvfb.log" 2>&1 &
export DISPLAY="${display}"
for _ in {1..50}; do xdpyinfo >/dev/null 2>&1 && break; sleep 0.1; done
xdpyinfo >/dev/null 2>&1 || { cat "${work}/xvfb.log" >&2; exit 3; }

"${binary}" "$@" >"${work}/mver.log" 2>&1 &
x11vnc -display "${display}" -localhost -forever -shared -nopw \
  >"${work}/x11vnc.log" 2>&1 &

echo "mver GUI preview: http://127.0.0.1:${port}/vnc.html?autoconnect=1&resize=scale"
echo "Use your sandbox/IDE port-forwarding UI to expose port ${port}."
exec websockify --web "${novnc_web}" "0.0.0.0:${port}" localhost:5900

