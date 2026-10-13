#!/usr/bin/env bash
# Collects the license files of every Go dependency of the helper (for all release
# targets) into one text file, so binary releases can reproduce the required notices.
# Usage: packaging/collect-licenses.sh [output-file]
set -euo pipefail
out="${1:-THIRD_PARTY_NOTICES.txt}"
main_module=$(go list -m)
list=$(mktemp)
trap 'rm -f "$list"' EXIT

for goos in windows linux darwin; do
  GOOS=$goos CGO_ENABLED=0 go list -deps -f '{{with .Module}}{{.Path}}@{{.Version}}|{{.Dir}}{{end}}' .
done | sort -u > "$list"

{
  echo "Third-party licenses for the ts-browser-ext helper binary"
  echo
  echo "=== Go standard library ==="
  cat "$(go env GOROOT)/LICENSE"
  while IFS='|' read -r mod dir; do
    [ -n "$dir" ] || continue
    case "$mod" in "$main_module"@*) continue ;; esac
    echo
    echo "=== $mod ==="
    found=0
    for f in "$dir"/LICENSE* "$dir"/LICENCE* "$dir"/COPYING* "$dir"/NOTICE* "$dir"/PATENTS*; do
      [ -f "$f" ] || continue
      found=1
      echo "--- $(basename "$f") ---"
      cat "$f"
      echo
    done
    [ "$found" = 1 ] || echo "(no license file found in this module; see its repository)"
  done < "$list"
} > "$out"
echo "wrote $out ($(grep -c '^=== ' "$out") entries)"
