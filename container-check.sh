#!/bin/bash

echo "🔍 Prüfe SSH-Host-Keys..."
ls -l /etc/ssh/ssh_host_* || echo "❌ SSH Host Keys fehlen"
echo

echo "🔍 Prüfe /etc/machine-id..."
if [[ -s /etc/machine-id ]]; then
	echo "✅ machine-id vorhanden: $(cat /etc/machine-id)"
else
	echo "❌ machine-id fehlt oder leer"
fi
echo

echo "🔍 Prüfe /run/systemd..."
if [[ -d /run/systemd ]]; then
	echo "✅ /run/systemd existiert"
	ls -ld /run/systemd
else
	echo "❌ /run/systemd fehlt"
fi
echo

echo "🔍 Prüfe systemd sshd-Einbindung..."
if [[ -L /etc/systemd/system/multi-user.target.wants/sshd.service ]]; then
	echo "✅ sshd Service ist verlinkt"
else
	echo "❌ sshd Service fehlt in systemd"
fi
echo

echo "🔍 Prüfe Benutzer 'vscode'..."
id vscode || echo "❌ Benutzer vscode nicht gefunden"
echo

echo "🔍 Prüfe /home/vscode..."
ls -ld /home/vscode || echo "❌ /home/vscode fehlt"
echo

echo "🔍 Prüfe /workspace Mount..."
ls -ld /workspace || echo "❌ /workspace nicht gemountet"
