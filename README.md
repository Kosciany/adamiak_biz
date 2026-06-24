# adamiak.biz

Statyczna strona kancelarii Doradcy Podatkowego Zbigniewa Adamiaka.

Zasada: **w repozytorium kod jest czytelny** (niezminifikowany), a optymalizacja
(minifikacja HTML/CSS/SVG, sprzątanie zbędnych plików) odbywa się dopiero
w GitHub Actions, tuż przed wysłaniem na serwer OVH.

## Struktura

| Plik / katalog | Rola |
| --- | --- |
| `index.html`, `style.css` | Źródło strony (czytelne) |
| `assets/` | Logo (SVG) + obrazy używane (`*.webp`) + oryginał certyfikatu (`adamiak_b-1.jpg`) |
| `map.webp` | Mapka dojazdu |
| `og-image.png`, `favicon.ico`, `apple-touch-icon.png`, `icon-192/512.png` | Ikony i obrazek do udostępniania |
| `robots.txt`, `sitemap.xml`, `site.webmanifest` | SEO / PWA |
| `.htaccess` | Konfiguracja serwera (gzip, cache, HTTPS, nagłówki) |
| `bootstrap-5.1.3-dist/` | Bootstrap (na serwer trafiają tylko 2 używane pliki) |
| `.github/workflows/` | `deploy.yml` (deploy) + `link-check.yml` (kontrola linków) |
| `screenshots.sh` | Lokalny podgląd responsywności |

## Podgląd lokalny

Otwórz `index.html` w przeglądarce. Aby sprawdzić responsywność w kilku
rozdzielczościach (mobile / tablet / desktop):

```bash
bash screenshots.sh        # wymaga Chromium; wynik w screenshots/ (ignorowany przez git)
```

W VS Code to samo odpalisz zadaniem **„Zrzuty ekranu (responsywność)"**
(menu Terminal → Run Task, albo skrót `Ctrl+Shift+B`).

Po deployu możesz porównać produkcję z lokalną wersją pixel-to-pixel —
zadanie **„prod-local-compare (pixel diff)"** lub `bash compare-prod-local.sh`
(zapisuje `*_diff.png` w `screenshots/compare/`; czerwone obszary = różnice).

## Deploy

Automatyczny przy każdym `push` na gałąź `master`. Workflow `deploy.yml`:

1. minifikuje `index.html`, `style.css` i SVG (`html-minifier-terser`, `csso`, `svgo`),
2. usuwa zbędne pliki (nieużywany Bootstrap, oryginały rastrowe — na serwer idą `*.webp`),
3. wysyła całość przez SCP do katalogu `www` na OVH.

Wymagane sekrety repozytorium: `FTP_SERVER`, `FTP_USERNAME`, `FTP_PRIVATE_KEY`.

> Jednorazowo warto wyczyścić na serwerze pozostałości po starych deployach
> (pełny katalog `bootstrap-5.1.3-dist` i nieużywane obrazy w `www/`), bo nowy
> deploy ich nie usuwa — tylko przestaje dosyłać.

## Kontrola linków

Workflow `link-check.yml` uruchamia się 1. i 15. dnia miesiąca (oraz ręcznie):

- **wpis KIDP** (`kidp.pl/doradca/00148`) — błąd zatrzymuje workflow (mail do właściciela repo),
- **pozostałe linki + mapa Google** — miękko: w razie problemu zakładane jest Issue
  (mapa Google bywa wrażliwa na boty, więc 403/429 traktujemy jako OK).

## Obrazy

Nowe zdjęcie konwertuj do WebP i podmień `src` w `index.html`:

```bash
cwebp -q 80 -resize 800 0 plik.png -o assets/plik.webp   # 800 px szerokości, proporcje auto
```

Oryginał certyfikatu (`assets/adamiak_b-1.jpg`) zostaje w repo. Inne oryginały
można usuwać — i tak są w historii git.

## Checklista przed publikacją (release)

- [ ] Dane firmy spójne we wszystkich sekcjach (nazwa, adres, nr wpisu)
- [ ] Telefony i e-mail aktualne (`tel:` w formacie `+48...`)
- [ ] Daty „Stan na:" w Polityce Prywatności i Cookies
- [ ] Link „Pokaż na mapie" prowadzi we właściwe miejsce
- [ ] Link do wpisu KIDP działa
- [ ] `bash screenshots.sh` — układ OK na mobile/tablet/desktop

