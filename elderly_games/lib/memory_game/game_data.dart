import 'models.dart';

const List<PhaseConfig> phases = [
  PhaseConfig(phase: 1, pairs: 4, rows: 2, cols: 4, theme: MemoryTheme.frutas, multiplier: 1.0, hasPreview: true),
  PhaseConfig(phase: 2, pairs: 5, rows: 2, cols: 5, theme: MemoryTheme.frutas, multiplier: 1.0, hasPreview: true),
  PhaseConfig(phase: 3, pairs: 6, rows: 3, cols: 4, theme: MemoryTheme.frutas, multiplier: 1.2, hasPreview: true),
  PhaseConfig(phase: 4, pairs: 6, rows: 3, cols: 4, theme: MemoryTheme.animais, timeLimitSeconds: 180, multiplier: 1.2, hasPreview: false),
  PhaseConfig(phase: 5, pairs: 8, rows: 4, cols: 4, theme: MemoryTheme.animais, timeLimitSeconds: 180, multiplier: 1.5, hasPreview: false),
  PhaseConfig(phase: 6, pairs: 8, rows: 4, cols: 4, theme: MemoryTheme.misto, timeLimitSeconds: 150, multiplier: 1.5, hasPreview: false),
  PhaseConfig(phase: 7, pairs: 10, rows: 4, cols: 5, theme: MemoryTheme.misto, timeLimitSeconds: 150, multiplier: 1.8, hasPreview: false),
  PhaseConfig(phase: 8, pairs: 12, rows: 4, cols: 6, theme: MemoryTheme.misto, timeLimitSeconds: 120, multiplier: 2.0, hasPreview: false),
];

const List<MemoryCard> frutasCards = [
  MemoryCard(id: 'maca', emoji: '\u{1F34E}', name: 'Maca', theme: MemoryTheme.frutas),
  MemoryCard(id: 'banana', emoji: '\u{1F34C}', name: 'Banana', theme: MemoryTheme.frutas),
  MemoryCard(id: 'uva', emoji: '\u{1F347}', name: 'Uva', theme: MemoryTheme.frutas),
  MemoryCard(id: 'laranja', emoji: '\u{1F34A}', name: 'Laranja', theme: MemoryTheme.frutas),
  MemoryCard(id: 'morango', emoji: '\u{1F353}', name: 'Morango', theme: MemoryTheme.frutas),
  MemoryCard(id: 'melancia', emoji: '\u{1F349}', name: 'Melancia', theme: MemoryTheme.frutas),
  MemoryCard(id: 'abacaxi', emoji: '\u{1F34D}', name: 'Abacaxi', theme: MemoryTheme.frutas),
  MemoryCard(id: 'pessego', emoji: '\u{1F351}', name: 'Pessego', theme: MemoryTheme.frutas),
];

const List<MemoryCard> animaisCards = [
  MemoryCard(id: 'gato', emoji: '\u{1F431}', name: 'Gato', theme: MemoryTheme.animais),
  MemoryCard(id: 'cachorro', emoji: '\u{1F436}', name: 'Cachorro', theme: MemoryTheme.animais),
  MemoryCard(id: 'passaro', emoji: '\u{1F426}', name: 'Passaro', theme: MemoryTheme.animais),
  MemoryCard(id: 'peixe', emoji: '\u{1F41F}', name: 'Peixe', theme: MemoryTheme.animais),
  MemoryCard(id: 'cavalo', emoji: '\u{1F434}', name: 'Cavalo', theme: MemoryTheme.animais),
  MemoryCard(id: 'coelho', emoji: '\u{1F430}', name: 'Coelho', theme: MemoryTheme.animais),
  MemoryCard(id: 'tartaruga', emoji: '\u{1F422}', name: 'Tartaruga', theme: MemoryTheme.animais),
  MemoryCard(id: 'borboleta', emoji: '\u{1F98B}', name: 'Borboleta', theme: MemoryTheme.animais),
];

List<MemoryCard> getCardsForTheme(MemoryTheme theme, int count) {
  List<MemoryCard> pool;
  switch (theme) {
    case MemoryTheme.frutas:
      pool = List.of(frutasCards);
    case MemoryTheme.animais:
      pool = List.of(animaisCards);
    case MemoryTheme.misto:
      pool = [...frutasCards, ...animaisCards];
  }
  pool.shuffle();
  return pool.take(count).toList();
}
