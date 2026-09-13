#!/usr/bin/env bash
# Liga as configuracoes do sistema aos arquivos deste repo.
# Uso: bash install.sh          (so a parte do usuario)
#      bash install.sh --xorg   (tambem copia o monitor virtual pra /etc/X11, pede sudo)
set -eu
R="$(cd "$(dirname "$0")" && pwd)"

link() { mkdir -p "$(dirname "$2")"; ln -sfn "$R/$1" "$2"; echo "$2 -> $R/$1"; }

link sunshine-tablet/sunshine.conf  "$HOME/.config/sunshine-tablet/sunshine.conf"
link sunshine-tablet/apps.json      "$HOME/.config/sunshine-tablet/apps.json"
link systemd/sunshine-tablet.service "$HOME/.config/systemd/user/sunshine-tablet.service"
link autostart/sunshine.desktop     "$HOME/.config/autostart/sunshine.desktop"
systemctl --user daemon-reload

# O X le isso no boot, antes do SSD montar: copia em vez de linkar.
if [[ "${1:-}" == "--xorg" ]]; then
  sudo install -m 644 "$R/xorg/edid-virtual.bin" /etc/X11/edid-virtual.bin
  sudo install -m 644 "$R/xorg/20-virtual-monitor.conf" /etc/X11/xorg.conf.d/20-virtual-monitor.conf
  echo "Monitor virtual instalado; reinicie a sessao grafica pra aplicar."
fi
