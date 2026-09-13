# Streaming do PC pro tablet

Configuração do Sunshine no Linux Mint (RTX 2060) pra transmitir um monitor virtual pro tablet via Moonlight, separado da tela principal.

- `xorg/`: monitor virtual `DP-0` sem hardware (EDID customizado no driver NVIDIA). Instalado em `/etc/X11/`.
- `sunshine-tablet/`: segunda instância do Sunshine (`PC-Tablet`, porta 48989) que transmite só o `DP-0`, sem áudio.
- `systemd/sunshine-tablet.service`: roda a segunda instância sem `/dev/uinput`. Assim o Sunshine usa o XTest e o toque do tablet cai na posição certa com vários monitores.
- `autostart/sunshine.desktop`: sobe as duas instâncias ao entrar na sessão. O Cinnamon não ativa o `graphical-session.target`.

O painel que roda no `DP-0` fica em [`../pc-dashboard`](../pc-dashboard).

## Instalação

```bash
bash install.sh          # liga ~/.config aos arquivos do repo (symlinks)
bash install.sh --xorg   # também instala o monitor virtual em /etc/X11 (sudo)
```

As chaves (`credentials/`) e os pareamentos (`sunshine_state.json`) ficam só em `~/.config/sunshine-tablet/` e não entram no repo.

## Segurança

Chaves, tokens e pareamentos nunca entram no repo: ficam em `~/.config`. O hook `.githooks/pre-commit` bloqueia commit com arquivo privado, formato de chave conhecido ou o valor real de alguma credencial local. Num clone novo, ative com `git config core.hooksPath .githooks`.
