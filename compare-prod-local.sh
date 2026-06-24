#!/usr/bin/env bash
#
# Porównanie pixel-to-pixel: lokalny index.html  vs  produkcja (www.adamiak.biz).
# Uruchamiaj PO pushu/deployu, żeby sprawdzić, czy produkcja renderuje się tak
# samo jak Twoja lokalna wersja. Czerwone obszary na *_diff.png = różnice.
#
#   bash compare-prod-local.sh
#
# Wymaga: Chromium + ImageMagick (compare).
set -uo pipefail
cd "$(dirname "$0")"

CHROME="$(command -v chromium-browser || command -v chromium || true)"
[ -z "$CHROME" ] && { echo "Brak Chromium. Zainstaluj: sudo apt install chromium-browser" >&2; exit 1; }
command -v compare >/dev/null 2>&1 || { echo "Brak ImageMagick. Zainstaluj: sudo apt install imagemagick" >&2; exit 1; }

LOCAL_URL="file://$(pwd)/index.html"
PROD_URL="https://www.adamiak.biz/"
OUT="screenshots/compare"
mkdir -p "$OUT"

shoot() { # url plik szer wys
  "$CHROME" --headless=new --no-sandbox --disable-gpu --hide-scrollbars \
    --disable-features=LazyImageLoading,LazyFrameLoading \
    --force-device-scale-factor=1 --virtual-time-budget=8000 \
    --window-size="$3,$4" --screenshot="$2" "$1" >/dev/null 2>&1
}

compare_one() { # nazwa szer wys
  local name="$1" w="$2" h="$3"
  echo "[$name ${w}x${h}]"
  shoot "$LOCAL_URL" "$OUT/${name}_local.png" "$w" "$h"
  shoot "$PROD_URL"  "$OUT/${name}_prod.png"  "$w" "$h"
  if [ ! -s "$OUT/${name}_prod.png" ]; then
    echo "  ! nie udało się pobrać produkcji (sieć / strona niedostępna)"; echo; return
  fi
  # AE = liczba różniących się pikseli; -fuzz toleruje drobny szum kompresji
  local diff total pct
  diff=$(compare -metric AE -fuzz 2% "$OUT/${name}_local.png" "$OUT/${name}_prod.png" "$OUT/${name}_diff.png" 2>&1)
  total=$(( w * h ))
  pct=$(awk "BEGIN{printf \"%.3f\", ($diff/$total)*100}" 2>/dev/null)
  printf "  różnice: %s / %s pikseli (%s%%)  ->  %s\n\n" "$diff" "$total" "$pct" "$OUT/${name}_diff.png"
}

echo "Lokalny:   $LOCAL_URL"
echo "Produkcja: $PROD_URL"
echo
compare_one mobile  390 6200
compare_one tablet  768 4800
compare_one desktop 1280 4400
echo "Gotowe. Im mniejszy %, tym lepiej. Obejrzyj *_diff.png (czerwone = różnice)."
