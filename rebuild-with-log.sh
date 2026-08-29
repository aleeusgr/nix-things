#!/bin/sh

# rebuild-with-log.sh — run nixos-rebuild and collect its warnings into a clean log
# Usage: ./rebuild-with-log.sh [boot|switch|test]   (default: switch)
# Result is kept in /tmp/nixos-rebuild-warnings.log (warnings only, deduplicated).

set -euo pipefail

ACTION="${1:-switch}"
LOG=/tmp/nixos-rebuild-warnings.log

sudo nixos-rebuild "$ACTION" --flake .#vivo --show-trace 2>&1 \
    | awk 'tolower($0) ~ /warning/' \
    | awk '!seen[$0]++' > "$LOG"

if [ -s "$LOG" ]; then
    N=$(wc -l < "$LOG")
    echo "== $N warning line(s) in $LOG =="
    cat "$LOG"
else
    echo "No warnings."
fi