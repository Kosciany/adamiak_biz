// Konfiguracja svgo używana przez krok minifikacji w GitHub Actions.
// Najważniejsze: NIE usuwamy viewBox — bez niego SVG w <img> o wymuszonym
// rozmiarze (np. logo w navbarze 30x24) rozjeżdża się / rozciąga.
module.exports = {
  multipass: true,
  plugins: [
    {
      name: 'preset-default',
      params: {
        overrides: {
          removeViewBox: false,
        },
      },
    },
  ],
};
