#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)/snapshots"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"

PATTERNS=(
    plasma*rc
    plasma-org.kde.plasma.desktop-appletsrc
    kdeglobals
    kdedefaults
    kwin*rc
    breezerc
    kglobalshortcutsrc
    kcminputrc
    kxkbrc
    krunnerrc
    ksmserverrc
    ksplashrc
    kscreenlockerrc
    powerdevilrc
)

current() {
    (cd "$CFG" && shopt -s nullglob && for p in "${PATTERNS[@]}"; do
        for f in $p; do [ -e "$f" ] && echo "$f"; done
    done) | sort -u
}

copy() {
    local from="$1" to="$2"; shift 2
    for f in "$@"; do
        [ -e "$from/$f" ] || continue
        rm -rf "${to:?}/$f"
        cp -a "$from/$f" "$to/"
    done
}

save() {
    local dest="$DIR/${1:-$(date +%Y-%m-%d_%H%M%S)}"
    mkdir -p "$dest"
    mapfile -t files < <(current)
    copy "$CFG" "$dest" "${files[@]}"
    ln -sfn "$(basename "$dest")" "$DIR/latest"
    echo "Saved ${#files[@]} entries to $dest"
}

# plasmashell rewrites its config on exit, so stop it before copying
stop_shell() {
    if systemctl --user is-active -q plasma-plasmashell.service 2>/dev/null; then
        SYSTEMD=1
        systemctl --user stop plasma-plasmashell.service
    else
        SYSTEMD=0
        kquitapp6 plasmashell 2>/dev/null || kquitapp5 plasmashell 2>/dev/null || true
    fi
}

start_shell() {
    if [ "$SYSTEMD" = 1 ]; then
        systemctl --user start plasma-plasmashell.service
    else
        (kstart plasmashell || kstart5 plasmashell) >/dev/null 2>&1 &
    fi
    qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
}

restore() {
    local name="${1:-latest}"
    [ "$name" = latest ] && name="$(readlink "$DIR/latest" 2>/dev/null || true)"
    local src="$DIR/$name"
    [ -n "$name" ] && [ -d "$src" ] || { echo "No snapshot '${1:-latest}'" >&2; exit 1; }

    mapfile -t files < <(ls -A "$src")

    local undo="$DIR/pre-restore_$(date +%Y-%m-%d_%H%M%S)"
    mkdir -p "$undo"
    copy "$CFG" "$undo" "${files[@]}"

    stop_shell
    copy "$src" "$CFG" "${files[@]}"
    start_shell

    echo "State saved at/$(basename "$undo")"
    echo "Restored $src"
}

case "${1:-}" in
    save) save "${2:-}" ;;
    restore) restore "${2:-}" ;;
    list) ls -1 "$DIR" 2>/dev/null | grep -v '^latest$' ;;
    files) current ;;
    *) echo "Usage: $(basename "$0") {save [name]|restore [snapshot]|list|files}"; exit 1 ;;
esac
