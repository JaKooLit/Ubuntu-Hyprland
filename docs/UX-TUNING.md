# Hyprland UX Tuning (Alacritty + Cosmic-style panels + Windows-like launcher)

This guide provides **modular, reversible** snippets for Hyprland, Waybar, Rofi, and Alacritty. Copy only the blocks you want and keep them in dedicated include files where possible (ex: `~/.config/hypr/conf.d/90-ux-tuning.conf`). Each block is annotated so you can remove it cleanly later.

---

## 1) Hyprland: default terminal + faster animations

> **File:** `~/.config/hypr/hyprland.conf` or a drop-in like `~/.config/hypr/conf.d/90-ux-tuning.conf`

```ini
# --- UX tuning: default terminal + Windows-like launcher key ---
$terminal = alacritty
$menu = rofi -show drun -show-icons -modi drun,run -matching fuzzy \
  -columns 6 -lines 5 -no-show-match -no-sort \
  -theme ~/.config/rofi/launcher-grid.rasi

# Windows-like Start menu on SUPER
bind = $mainMod, SPACE, exec, $menu

# Optional: tmux on demand (keeps default terminal non-forced)
bind = $mainMod, RETURN, exec, $terminal
bind = $mainMod SHIFT, RETURN, exec, $terminal -e tmux new-session -A -s main

# --- UX tuning: faster, less sticky animations ---
animations {
  enabled = 1
  # Simple, snappy curve
  bezier = fast, 0.2, 0.0, 0.2, 1.0

  # Reduce durations for responsiveness
  animation = windows, 1, 3, fast
  animation = borders, 1, 2, fast
  animation = fade, 1, 2, fast
  animation = workspaces, 1, 2, fast, slide
}
```

**Why this helps**
- Keeps Alacritty as the default terminal, avoids kitty entirely.
- Adds a Start-menu style launcher on **SUPER + Space** for quick app access.
- Shorter durations + simple bezier curve reduce “sticky” feeling while retaining polish.

---

## 2) Waybar: Cosmic-style panel (clean, spaced, readable)

> **Files:** `~/.config/waybar/config` and `~/.config/waybar/style.css`

**Config (minimal + clean layout):**
```jsonc
// Place this in ~/.config/waybar/config or include in config.d/
{
  "layer": "top",
  "position": "top",
  "height": 34,
  "spacing": 12,
  "modules-left": ["hyprland/workspaces", "hyprland/window"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "network", "battery", "tray"]
}
```

**CSS (Cosmic-like spacing + low noise):**
```css
/* ~/.config/waybar/style.css */
* {
  font-family: "Inter", "Noto Sans", sans-serif;
  font-size: 12px;
}

window#waybar {
  background: rgba(20, 22, 27, 0.92);
  color: #E6E8EE;
  border-radius: 12px;
  margin: 6px 10px;
  padding: 6px 12px;
}

#workspaces button {
  padding: 2px 8px;
  margin: 0 3px;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.04);
}

#workspaces button.active {
  background: rgba(255, 255, 255, 0.18);
}

#clock, #pulseaudio, #network, #battery, #tray, #window {
  padding: 0 6px;
}
```

**Why this helps**
- Minimal module set reduces visual noise and keeps the panel readable.
- Soft background, rounded corners, and consistent spacing mimic COSMIC’s clean UX.

---

## 3) Rofi: Windows-like launcher (grid + search)

> **Files:** `~/.config/rofi/config.rasi` + `~/.config/rofi/launcher-grid.rasi`

**Basic config:**
```rasi
configuration {
  modi: "drun,run";
  show-icons: true;
  drun-display-format: "{name}";
  display-drun: "Apps";
  matching: "fuzzy";
  kb-primary-paste: "Control+V,Shift+Insert";
}
```

**Grid theme (launcher-grid.rasi):**
```rasi
* {
  font: "Inter 12";
  background: #12141a;
  foreground: #e6e8ee;
  accent: #7aa2f7;
}

window {
  width: 780px;
  border-radius: 12px;
  padding: 12px;
  background-color: @background;
}

mainbox {
  spacing: 12px;
}

listview {
  columns: 6;
  lines: 5;
  spacing: 8px;
  fixed-height: true;
}

element {
  padding: 8px;
  border-radius: 10px;
}

element selected {
  background-color: rgba(122, 162, 247, 0.2);
}
```

**Why this helps**
- Grid + search delivers a familiar Start-menu feel.
- Smooth, compact theme keeps the launcher fast and focused.

---

## 4) Alacritty + tmux: clean integration (no forced sessions)

> **File:** `~/.config/alacritty/alacritty.toml`

```toml
[window]
padding = { x = 8, y = 6 }
decorations = "full"

[font]
size = 11.5

[cursor]
style = "Beam"
```

**Optional tmux usage (manual, no forced session):**
```bash
# Use this when you want tmux, without forcing it for every terminal:
alacritty -e tmux new-session -A -s main
```

**Why this helps**
- Keeps Alacritty lightweight and responsive.
- tmux remains opt-in, so you avoid “forced” workflows.
