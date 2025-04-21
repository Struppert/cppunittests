#!/bin/bash

set -e

IMAGE_NAME="cppdev"
CONTAINER_NAME="cppdev"
WORKDIR="$PWD"

echo "🧠 Erkenne UID/GID..."
HOST_UID=$(id -u)
HOST_GID=$(id -g)

echo "🧹 Prüfe Dateibesitz im Projektverzeichnis..."
BAD_OWNERS=$(find "$WORKDIR" ! -user "$USER" 2>/dev/null | wc -l)
if [ "$BAD_OWNERS" -gt 0 ]; then
	echo "⚠️  Einige Dateien gehören nicht dir. Behebe das..."
	sudo chown -R "$USER:$USER" "$WORKDIR"
else
	echo "✅ Alle Dateien gehören dir."
fi

echo "🛠 Baue Docker-Image '$IMAGE_NAME'..."
podman build \
	-t "$IMAGE_NAME" \
	--build-arg HOST_UID="$HOST_UID" \
	--build-arg HOST_GID="$HOST_GID" \
	--build-arg GITHUB_TOKEN="$GITHUB_TOKEN" \
	-f .devcontainer/Dockerfile .

echo "🧨 Stoppe & entferne evtl. existierenden Container..."
podman rm -f "$CONTAINER_NAME" 2>/dev/null || true

echo "🧹 Lösche altes build-Verzeichnis im Projekt (falls vorhanden)..."
rm -rf "$WORKDIR/build"

echo "🖼️  Prüfe Wayland..."
WAYLAND_MOUNTS=""
if [[ -n "$WAYLAND_DISPLAY" && -n "$XDG_RUNTIME_DIR" && -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]]; then
	echo "✅ Wayland-Clipboard aktiv – $WAYLAND_DISPLAY"
	WAYLAND_MOUNTS="-e WAYLAND_DISPLAY=$WAYLAND_DISPLAY -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR"
else
	echo "ℹ️  Kein Wayland-Socket gefunden – Clipboard im Container deaktiviert"
fi

echo "🚀 Starte Container '$CONTAINER_NAME' mit systemd (explizit aktiviert)..."
podman run -it --rm \
	--privileged \
	--name cppdev \
	--userns=keep-id \
	--cap-add=SYS_ADMIN \
	--security-opt=label=disable \
	--tmpfs /tmp \
	--tmpfs /run \
	--tmpfs /run/lock \
	-v /sys/fs/cgroup:/sys/fs/cgroup:rw \
	-v "$PWD":/workspace \
	-v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$WAYLAND_DISPLAY:ro" \
	-w /workspace \
	-p 2222:22 \
	-e container=podman \
	-e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
	-e XDG_RUNTIME_DIR=/tmp \
	--hostname cppdev \
	--systemd=always \
	cppdev \
	/lib/systemd/systemd
