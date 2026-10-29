# My Shortcuts — an Omarchy bar widget

Super + K shows *every* Omarchy keybinding. This shows only **yours**.

A single bar icon opens the same searchable menu, listing the keybindings you
added yourself (read live from `~/.config/hypr/bindings.lua`) plus any extra
rows you want to remember. Pick a row and it runs.

![A keyboard icon in the Omarchy bar that opens a searchable list of your own shortcuts](screenshot.png)

## Install

```bash
omarchy plugin add https://github.com/robbied112/omarchy-my-shortcuts.git --enable
```

New plugins stay disabled until you enable them, so you can read the code first.
The widget lands in the right section of the bar; move it with
`omarchy bar move robbied112.my-shortcuts --section left`.

Optional keybinding, in `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + ALT + H", "My shortcuts", "~/.config/omarchy/plugins/robbied112.my-shortcuts/my-shortcuts.sh")
```

## How it works

- **Left-click** the icon: the menu. Type to filter, Enter to run.
- **Right-click**: opens the extras file in your editor.
- Every `o.bind("KEY", "Description", "command")` line in your bindings file
  becomes a row, including the description you gave it. Commented-out examples
  are skipped. Bindings whose action is a Lua table (`{ launch = ... }`) are
  listed but not runnable from the menu.
- Extras live in `~/.config/omarchy/my-shortcuts.extra`, one per line as
  `label<TAB>command`. Leave the command empty for a reminder-only row.

```
Obsidian — new notes auto-sync to my notes app	obsidian
Super + K — every Omarchy shortcut	omarchy-menu-keybindings
Pause (hold) — dictate anywhere	
```

## Settings

Set in `~/.config/omarchy/shell.json` on the widget entry, or via the bar settings UI:

| key            | default                              | meaning                                  |
|----------------|--------------------------------------|------------------------------------------|
| `glyph`        | `󰌌`                                  | Bar icon (any Nerd Font glyph)           |
| `bindingsFile` | `~/.config/hypr/bindings.lua`        | File to read `o.bind(...)` lines from    |
| `extrasFile`   | `~/.config/omarchy/my-shortcuts.extra` | Extra rows                             |
| `menuWidth`    | `980`                                | Menu width in pixels                     |

## Why

Omarchy is easy to customise and easy to forget what you customised. This keeps
the list in front of you without maintaining a separate document: the bindings
file is the source of truth.

## License

MIT
