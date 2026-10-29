#!/usr/bin/env bash
# My Shortcuts menu for Omarchy.
#
# Lists every o.bind(...) in your personal bindings file plus the rows in an
# extras file, in Omarchy's searchable select menu (the same UI as Super+K).
# Picking a row runs its command.
#
#   my-shortcuts.sh [--bindings FILE] [--extras FILE] [--width PX]
#   my-shortcuts.sh --print            # list rows to stdout (no menu)
#   my-shortcuts.sh --edit-extras      # open the extras file in your editor
#
# Extras file format: one row per line, "label<TAB>command". An empty command
# makes an info-only row. Lines starting with # are comments.
set -uo pipefail

BINDINGS="$HOME/.config/hypr/bindings.lua"
EXTRA="$HOME/.config/omarchy/my-shortcuts.extra"
WIDTH=980
PRINT=0
EDIT=0
expand_tilde() { printf '%s' "${1/#\~/$HOME}"; }

while (( $# > 0 )); do
  case "$1" in
    --bindings) BINDINGS=$(expand_tilde "$2"); shift ;;
    --extras)   EXTRA=$(expand_tilde "$2"); shift ;;
    --width)    WIDTH="$2"; shift ;;
    --print|-p) PRINT=1 ;;
    --edit-extras) EDIT=1 ;;
    -h|--help)  sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

if (( EDIT )); then
  if [[ ! -f "$EXTRA" ]]; then
    mkdir -p "$(dirname "$EXTRA")"
    printf '# My Shortcuts extras: one row per line, "label<TAB>command".\n# Empty command = info-only row. Lines starting with # are ignored.\n# Example:\n# Super + K — every Omarchy shortcut\tomarchy-menu-keybindings\n' > "$EXTRA"
  fi
  exec omarchy launch editor "$EXTRA"
fi

declare -A cmd_of
labels=()
add() {  # label, command
  local label="$1"
  while [[ -n "${cmd_of[$label]+x}" ]]; do label="$label "; done   # keep duplicate labels distinct
  cmd_of["$label"]="$2"; labels+=("$label")
}
fmt() { printf '%-26s %s' "$1" "$2"; }

# o.bind("KEY", "Description", "command") — string commands run; table commands
# ({ launch = ... }) are listed but can't be run from here.
if [[ -f "$BINDINGS" ]]; then
  while IFS= read -r line; do
    [[ "${line#"${line%%[![:space:]]*}"}" == --* ]] && continue      # Lua comment
    if [[ "$line" =~ o\.bind\(\"([^\"]+)\",[[:space:]]*\"([^\"]*)\",[[:space:]]*\"([^\"]*)\" ]]; then
      [[ "$line" == *"release = true"* ]] && continue                 # key-up half of a hold binding
      add "$(fmt "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}")" "${BASH_REMATCH[3]}"
    elif [[ "$line" =~ o\.bind\(\"([^\"]+)\",[[:space:]]*\"([^\"]*)\" ]]; then
      add "$(fmt "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}")" ""
    fi
  done < "$BINDINGS"
fi

if [[ -f "$EXTRA" ]]; then
  while IFS=$'\t' read -r label cmd; do
    [[ -z "$label" || "$label" == \#* ]] && continue
    add "$label" "${cmd:-}"
  done < "$EXTRA"
fi

if (( ${#labels[@]} == 0 )); then
  labels+=("No custom bindings yet — add o.bind(...) lines to $BINDINGS")
fi

if (( PRINT )); then printf '%s\n' "${labels[@]}"; exit 0; fi

pick=$(omarchy menu select "My shortcuts" "${labels[@]}" -- --width "$WIDTH") || exit 0
[[ -z "$pick" ]] && exit 0
cmd="${cmd_of[$pick]:-}"
[[ -z "$cmd" ]] && exit 0
setsid -f bash -lc "$cmd" >/dev/null 2>&1
