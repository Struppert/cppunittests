#!/bin/bash
set -e

# Falls kein Argument übergeben wird, setze den Standardbefehl
if [ "$#" -eq 0 ]; then
	set -- /lib/systemd/systemd
fi

# Wenn der übergebene Befehl systemd ist, starte ihn als root.
if [ "$1" = "/lib/systemd/systemd" ]; then
	echo "Starting systemd as root..."
	exec /lib/systemd/systemd
else
	# Andernfalls führe den Befehl als vscode aus.
	echo "Executing command as vscode: $@"
	exec gosu vscode "$@"
fi
