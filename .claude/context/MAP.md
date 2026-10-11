---
updated: 2026-10-03
tier: 1
---

# Mapa do projeto

<!-- TETO: 60 linhas FORA do bloco auto (o bloco é do script e não conta). O `git log` guarda o resto. -->

## Comandos

<!-- auto:start -->
gerado em: 2026-10-03

primeiro nível:

```
autostart
install.sh
LICENSE
README.md
sunshine-tablet
systemd
xorg
```
<!-- auto:end -->

Sem build nem testes: o repo é só config + `install.sh`.
- `bash install.sh` — symlinka `sunshine-tablet/`, `systemd/`, `autostart/` em `~/.config` e faz `systemctl --user daemon-reload`
- `bash install.sh --xorg` — também COPIA `xorg/*` pra `/etc/X11` (sudo); reiniciar a sessão gráfica depois
- `git config core.hooksPath .githooks` — liga o hook anti-vazamento (uma vez por clone)
- Verificar: `xrandr` mostra `DP-0` conectado; `systemctl --user status sunshine-tablet`; log em `~/.config/sunshine-tablet/sunshine.log`; painel web `https://localhost:48990`

## Onde fica cada coisa

<!-- caminho → o que tem lá. Só o que não é óbvio pelo nome. -->
- `xorg/20-virtual-monitor.conf` — `ConnectedMonitor` (lista monitores reais HDMI-0, DP-4 + o virtual DP-0), `BusID` da GPU, `CustomEDID`
- `xorg/edid-virtual.bin` — EDID genérico 1920×1080 do monitor virtual
- `sunshine-tablet/sunshine.conf` — 2ª instância: porta 48989, `output_name = 0`, sem áudio, paths absolutos em `/home/meketreve`
- `systemd/sunshine-tablet.service` — `InaccessiblePaths=/dev/uinput` força o fallback XTest (toque certo com vários monitores)
- `autostart/sunshine.desktop` — sobe as DUAS instâncias (Cinnamon não ativa `graphical-session.target`)
- `.githooks/pre-commit` — barra `credentials/`, `*.pem`, `sunshine_state.json`, padrões de token e valores reais de `~/.config/toca-do-texugo/redes*.json`

## Pontos de entrada e fluxos principais

<!-- ex.: requisição chega em X → passa por Y → grava em Z -->
- Boot: X lê `/etc/X11/xorg.conf.d/20-virtual-monitor.conf` → driver NVIDIA cria `DP-0` virtual com o EDID
- Login: `autostart/sunshine.desktop` → importa DISPLAY/XAUTHORITY → inicia `app-dev.lizardbyte.app.Sunshine.service` (tela principal, 47989) + `sunshine-tablet.service` (DP-0, 48989)
- Tablet: Moonlight em `IP-do-PC:48989` → pareia pelo painel `https://localhost:48990`
- Chaves/pareamentos ficam só em `~/.config/sunshine-tablet/` — nunca no repo (`.gitignore` + hook)
