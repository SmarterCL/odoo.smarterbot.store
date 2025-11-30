#!/usr/bin/env bash
set -euo pipefail
INPUT=${1:-static/img}
OUTPUT=${2:-static/img/optimized}
mkdir -p "$OUTPUT"
for f in "$INPUT"/*.{jpg,png}; do
  [ -e "$f" ] || continue
  base=$(basename "$f")
  if command -v cwebp >/dev/null 2>&1; then
    cwebp -q 82 "$f" -o "$OUTPUT/${base%.*}.webp" >/dev/null 2>&1 || echo "WebP fallo: $f"
  fi
  if command -v magick >/dev/null 2>&1; then
    magick "$f" -resize 1280x1280\> -strip -quality 82 "$OUTPUT/$base"
  fi
done
printf "Optimización completa en %s\n" "$OUTPUT"
