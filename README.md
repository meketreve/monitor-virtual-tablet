# 📺 Streaming do PC pro tablet

Transforma um tablet num **segundo monitor sem fio** no Linux: cria um monitor virtual na placa NVIDIA (sem nada plugado) e transmite só ele pro tablet com uma **segunda instância do Sunshine**, via Moonlight. A instância normal do Sunshine continua transmitindo a tela principal, pra jogar ou acessar o PC.

Uso isso pra deixar a [**Toca do Texugo**](https://github.com/meketreve/toca-do-texugo), o painel do meu PC, sempre aberta no tablet.

## Como funciona

```
Placa NVIDIA
 ├─ HDMI-0, DP-4 ─► monitores de verdade ─► Sunshine principal (porta 47989)
 └─ DP-0 (virtual, EDID falso) ────────────► Sunshine "PC-Tablet" (porta 48989) ─► Moonlight no tablet
```

- **Monitor virtual (`xorg/`)**: a opção `ConnectedMonitor` do driver NVIDIA faz o X achar que tem um monitor no `DP-0`, e o `CustomEDID` diz qual resolução ele aceita (EDID genérico 1920×1080). Como o `ConnectedMonitor` desliga a detecção automática, os monitores de verdade também precisam estar na lista.
- **Segunda instância do Sunshine (`sunshine-tablet/`)**: porta própria (48989), transmite só a saída `0` (o `DP-0`), sem áudio, com estado, pareamentos e certificados separados da instância principal.
- **Toque certo no tablet (`systemd/`)**: o serviço roda sem acesso a `/dev/uinput`. Assim o Sunshine usa o XTest do X11, que posiciona o toque certo mesmo com vários monitores. O mouse virtual do libvirtualhid mistura eixos relativos e absolutos, e o libinput ignora os absolutos.
- **Autostart (`autostart/`)**: o Cinnamon não ativa o `graphical-session.target`, então as duas instâncias são iniciadas pelo autostart da sessão.

## Adaptando pra tua máquina

1. **Monitor virtual**: em `xorg/20-virtual-monitor.conf`, ajuste:
   - `BusID`: o endereço da tua GPU (veja com `lspci | grep -i vga`; `03:00.0` vira `PCI:3:0:0`)
   - `ConnectedMonitor`: os monitores de verdade (veja com `xrandr`) **mais** a saída livre que vai virar virtual
   - a saída do `CustomEDID`, se não for `DP-0`
2. **Sunshine do tablet**: em `sunshine-tablet/sunshine.conf`, troque `/home/meketreve` pelo teu home. Se o monitor virtual não for a saída `0`, ajuste o `output_name` (o log do Sunshine lista as saídas quando inicia).
3. **Sunshine instalado** como o pacote/flatpak do LizardByte. O autostart chama o serviço `app-dev.lizardbyte.app.Sunshine.service`; se o teu tiver outro nome, ajuste `autostart/sunshine.desktop`.

## Instalação

```bash
git config core.hooksPath .githooks   # trava contra commit de chaves (ver Segurança)
bash install.sh                        # liga ~/.config aos arquivos do repo (symlinks)
bash install.sh --xorg                 # também instala o monitor virtual em /etc/X11 (pede sudo)
```

Depois do `--xorg`, reinicie a sessão gráfica. O `DP-0` aparece no `xrandr` como conectado.

No tablet, adicione o PC no Moonlight pelo IP **com a porta**, no formato `IP-do-PC:48989`, e pareie pelo painel web da instância do tablet em `https://localhost:48990`.

Pra desfazer o monitor virtual: `sudo rm /etc/X11/xorg.conf.d/20-virtual-monitor.conf /etc/X11/edid-virtual.bin` e reinicie a sessão.

## Arquivos

| Arquivo | Vai pra |
|---|---|
| `xorg/20-virtual-monitor.conf`, `xorg/edid-virtual.bin` | `/etc/X11/` (copiados: o X lê no boot, antes de montar outros discos) |
| `sunshine-tablet/sunshine.conf`, `sunshine-tablet/apps.json` | `~/.config/sunshine-tablet/` (symlink) |
| `systemd/sunshine-tablet.service` | `~/.config/systemd/user/` (symlink) |
| `autostart/sunshine.desktop` | `~/.config/autostart/` (symlink) |

## Segurança

As chaves (`credentials/`) e os pareamentos (`sunshine_state.json`) do Sunshine ficam só em `~/.config/sunshine-tablet/` e **nunca** entram no repo. O `.gitignore` bloqueia esses arquivos, e o hook `.githooks/pre-commit` barra o commit se aparecer arquivo privado, formato de chave conhecido ou o valor real de alguma credencial local.

## Licença

[MIT](LICENSE)
