#!/usr/bin/env bash
#
# Zrzuty ekranu strony w kilku rozdzielczościach — do podglądu responsywności
# przed commitem. Wymaga lokalnego Chromium.
#
#   bash screenshots.sh
#
# Wynik trafia do katalogu screenshots/ (ignorowanego przez git).
set -euo pipefail
cd "$(dirname "$0")"

CHROME="$(command -v chromium-browser || command -v chromium || true)"
if [ -z "$CHROME" ]; then
  echo "Brak Chromium. Zainstaluj: sudo apt install chromium-browser" >&2
  exit 1
fi

URL="file://$(pwd)/index.html"
OUT="screenshots"
mkdir -p "$OUT"

shot() { # nazwa szerokość wysokość
  # --disable-features=LazyImageLoading: bez tego obrazy loading="lazy" bywają
  # puste w headless (brak realnego scrolla). To dotyczy tylko zrzutów, nie strony.
  "$CHROME" --headless=new --no-sandbox --disable-gpu --hide-scrollbars \
    --disable-features=LazyImageLoading,LazyFrameLoading \
    --force-device-scale-factor=1 --virtual-time-budget=6000 \
    --window-size="$2,$3" --screenshot="$OUT/$1.png" "$URL" >/dev/null 2>&1
  echo "  $OUT/$1.png  (${2}x${3})"
}

echo "Generuję zrzuty ekranu:"
shot mobile  390 6200
shot tablet  768 4800
shot desktop 1280 4400
echo "Gotowe — przejrzyj katalog $OUT/ i dopiero potem commituj."
