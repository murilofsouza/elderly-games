/// Word bank for the Word Search game.
///
/// Rules enforced here:
/// - All entries are UPPERCASE and accent-free (safe for the letter grid).
/// - Words are 3–8 characters long.
/// - Cities with spaces have them removed (e.g. "Sao Paulo" → "SAOPAULO").
/// - Each theme contains at least 15 words.
const Map<String, List<String>> wordSearchBank = {
  // ── Frutas ─────────────────────────────────────────────────────────────────
  'Frutas': [
    'MACA',     // 4 – Maçã
    'BANANA',   // 6
    'UVA',      // 3
    'LARANJA',  // 7
    'MORANGO',  // 7
    'MELANCIA', // 8
    'ABACAXI',  // 7
    'PESSEGO',  // 7 – Pêssego
    'LIMA',     // 4
    'COCO',     // 4
    'MANGA',    // 5
    'AMORA',    // 5
    'FIGO',     // 4
    'PERA',     // 4
    'CAJU',     // 4
    'KIWI',     // 4
  ],

  // ── Animais ────────────────────────────────────────────────────────────────
  'Animais': [
    'GATO',     // 4
    'CACHORRO', // 8
    'PEIXE',    // 5
    'CAVALO',   // 6
    'COELHO',   // 6
    'PATO',     // 4
    'URSO',     // 4
    'LEAO',     // 4 – Leão
    'VACA',     // 4
    'RATO',     // 4
    'GALO',     // 4
    'PORCO',    // 5
    'SAPO',     // 4
    'LOBO',     // 4
    'TIGRE',    // 5
    'CORUJA',   // 6
  ],

  // ── Cores ──────────────────────────────────────────────────────────────────
  'Cores': [
    'AZUL',     // 4
    'VERMELHO', // 8
    'VERDE',    // 5
    'AMARELO',  // 7
    'ROXO',     // 4
    'BRANCO',   // 6
    'PRETO',    // 5
    'ROSA',     // 4
    'CINZA',    // 5
    'LARANJA',  // 7
    'DOURADO',  // 7
    'PRATA',    // 5
    'MARROM',   // 6
    'LILAS',    // 5 – Lilás
    'BEGE',     // 4
    'TURQUESA', // 8
  ],

  // ── Cidades ────────────────────────────────────────────────────────────────
  // Spaces removed; FORTALEZA (9) exceeds 8 chars and will be filtered
  // out by the generator for smaller grids.
  'Cidades': [
    'RIO',       // 3
    'NATAL',     // 5
    'BELEM',     // 5 – Belém
    'PALMAS',    // 6
    'RECIFE',    // 6
    'MANAUS',    // 6
    'MACEIO',    // 6 – Maceió
    'MACAPA',    // 6 – Macapá
    'ARACAJU',   // 7
    'VITORIA',   // 7 – Vitória
    'GOIANIA',   // 7 – Goiânia
    'SALVADOR',  // 8
    'BRASILIA',  // 8 – Brasília
    'CURITIBA',  // 8
    'SAOPAULO',  // 8 – São Paulo
    'FORTALEZA', // 9 – filtered for grids < 9
  ],
};

/// Themes available to the player (display names).
const List<String> wordSearchThemes = [
  'Frutas',
  'Animais',
  'Cores',
  'Cidades',
];

/// Returns the word list for [theme], optionally filtered to [maxLength].
List<String> wordsForTheme(String theme, {int? maxLength}) {
  final words = List<String>.from(wordSearchBank[theme] ?? []);
  if (maxLength != null) {
    words.removeWhere((w) => w.length > maxLength);
  }
  return words;
}
