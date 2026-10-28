# hypr-volume-scroll

Volume control on your mouse wheel in Hyprland — with **speed-adaptive steps** and a
debounced on-screen display.

I use it every day: `SUPER + ALT + scroll up/down` changes the volume of the current
default sink. A single tick nudges by 10%; if you keep scrolling, each tick gets bigger
(up to 10% here, configurable) so you can go from quiet to loud in one flick.

## Why another volume script?

Media keys already work. What I wanted was:

- **No workspace hijack.** `SUPER + scroll` keeps switching workspaces; volume lives on
  `SUPER + ALT + scroll`.
- **Follows the default sink.** The sink is resolved as `@DEFAULT_SINK@` on every tick,
  so switching between speakers and headphones never leaves you adjusting a dead device.
- **Adaptive, not linear.** Slow tick = fine step. Fast burst = bigger steps, capped.
  The step is recomputed from the **real current volume**, so changes made elsewhere
  (media keys, another app, a mixer) never desync it.
- **Hard limits.** Never exceeds 100%, never goes below 0%.
- **One OSD per burst.** Fires an `omarchy-osd` notification only after the scroll
  settles (180 ms debounce), instead of spamming one per tick.
- **Zero extra daemons.** Pure bash + `pactl`. No Python, no event listener, no config
  reload needed — the script reads its tuning from the environment on every tick.

## Requirements

- Hyprland
- `pactl` (PipeWire's `pipewire-pulse` or PulseAudio)
- Bash, GNU `date` (uses `%3N` milliseconds)
- Optional: [`omarchy-osd`](https://github.com/basecamp/omarchy) for the volume overlay.
  Without it, volume still changes; only the on-screen indicator is skipped.

## Install

```bash
git clone https://github.com/joaovfnandes/hypr-volume-scroll.git
cd hypr-volume-scroll
./install.sh
```

`install.sh` copies `volume-scroll` to `~/.local/bin` and prints the binding lines to add
to your Hyprland config. It does **not** touch your existing config.

Make sure `~/.local/bin` is in `PATH` — or call the script by absolute path, as the
example bindings do.

## Bindings

### Lua config (`~/.config/hypr/bindings.lua`)

```lua
-- Volume via SUPER+ALT+scroll (keeps SUPER+scroll = workspaces)
hl.unbind("SUPER + ALT + mouse_up")
hl.unbind("SUPER + ALT + mouse_down")
o.bind("SUPER + ALT + mouse_up", "Volume up", "/home/USER/.local/bin/volume-scroll +")
o.bind("SUPER + ALT + mouse_down", "Volume down", "/home/USER/.local/bin/volume-scroll -")
```

### Legacy `.conf` config (`~/.config/hypr/bindings.conf`)

```conf
bind = SUPER ALT, mouse_up, exec, /home/USER/.local/bin/volume-scroll +
bind = SUPER ALT, mouse_down, exec, /home/USER/.local/bin/volume-scroll -
```

The two `unbind` calls matter: Hyprland's defaults bind `SUPER + ALT + scroll` to group
navigation, and without unbinding, both actions fire.

## Usage

```bash
volume-scroll +          # adaptive step, up
volume-scroll -          # adaptive step, down
volume-scroll +5         # fixed 5% step, up
volume-scroll -15        # fixed 15% step, down
volume-scroll --status   # current tuning + volume
```

## Tuning

Tuning is read from the environment on each tick, so you only need to export it once
(e.g. in `~/.config/hypr/envs.conf` or your shell profile):

| Variable | Default | Meaning |
| --- | --- | --- |
| `VOL_SCROLL_FINE` | `10` | Step (in %) for a single, isolated tick |
| `VOL_SCROLL_MAX` | `10` | Maximum step (in %) during a fast burst |
| `VOL_SCROLL_RESET_MS` | `300` | Gap in ms that ends a burst and resets to the fine step |

```bash
VOL_SCROLL_FINE=2 VOL_SCROLL_MAX=20 volume-scroll +
```

The step grows as `FINE + burst`, capped at `MAX`. With the defaults, every tick in a
burst is already at the cap — raise `VOL_SCROLL_MAX` if you want the acceleration to be
visible.

## How it works

```
scroll tick
   │
   ├─ read last tick timestamp from $XDG_RUNTIME_DIR/volume-scroll.vel
   ├─ dt > RESET_MS ? burst = 0, step = FINE : burst++, step = min(FINE+burst, MAX)
   ├─ clamp step against the real volume (never >100, never <0)
   ├─ pactl set-sink-volume @DEFAULT_SINK@ ±step%
   └─ write OSD stamp, sleep 180ms, show omarchy-osd only if no newer tick arrived
```

State lives in `$XDG_RUNTIME_DIR` (falls back to `/tmp`), so it is per-user and cleaned
up automatically on reboot.

## License

MIT — see [LICENSE](LICENSE).

---

## Em português

Volume no scroll do mouse, no Hyprland, com passo adaptativo à velocidade do scroll.

`SUPER + ALT + scroll` sobe/desce o volume do sink padrão. Um tick isolado muda 10%;
se você continuar rolando, o passo cresce até o máximo configurado. O volume nunca passa
de 100% nem desce abaixo de 0%, e o OSD (`omarchy-osd`) só aparece quando a rajada
termina.

Instalação: `./install.sh` copia o script para `~/.local/bin` e imprime as linhas de
binding para colar no seu config. O instalador não mexe no seu Hyprland.

Ajuste fino por variáveis de ambiente: `VOL_SCROLL_FINE`, `VOL_SCROLL_MAX`,
`VOL_SCROLL_RESET_MS`.
