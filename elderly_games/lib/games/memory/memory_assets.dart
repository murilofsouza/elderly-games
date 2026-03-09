import 'memory_models.dart';

// Each entry is a template card. imageAsset holds the emoji placeholder
// and will be swapped for a real asset path when photo assets are added.
// These are NOT const because MemoryCard has mutable state fields.
final List<MemoryCard> _fruitsPool = [
  MemoryCard(id: 1, imageAsset: '🍎', label: 'Maçã',      theme: MemoryTheme.fruits),
  MemoryCard(id: 2, imageAsset: '🍌', label: 'Banana',    theme: MemoryTheme.fruits),
  MemoryCard(id: 3, imageAsset: '🍇', label: 'Uva',       theme: MemoryTheme.fruits),
  MemoryCard(id: 4, imageAsset: '🍊', label: 'Laranja',   theme: MemoryTheme.fruits),
  MemoryCard(id: 5, imageAsset: '🍓', label: 'Morango',   theme: MemoryTheme.fruits),
  MemoryCard(id: 6, imageAsset: '🍉', label: 'Melancia',  theme: MemoryTheme.fruits),
  MemoryCard(id: 7, imageAsset: '🍍', label: 'Abacaxi',   theme: MemoryTheme.fruits),
  MemoryCard(id: 8, imageAsset: '🍑', label: 'Pêssego',   theme: MemoryTheme.fruits),
];

final List<MemoryCard> _animalsPool = [
  MemoryCard(id: 9,  imageAsset: '🐱', label: 'Gato',      theme: MemoryTheme.animals),
  MemoryCard(id: 10, imageAsset: '🐶', label: 'Cachorro',  theme: MemoryTheme.animals),
  MemoryCard(id: 11, imageAsset: '🐦', label: 'Pássaro',   theme: MemoryTheme.animals),
  MemoryCard(id: 12, imageAsset: '🐟', label: 'Peixe',     theme: MemoryTheme.animals),
  MemoryCard(id: 13, imageAsset: '🐴', label: 'Cavalo',    theme: MemoryTheme.animals),
  MemoryCard(id: 14, imageAsset: '🐰', label: 'Coelho',    theme: MemoryTheme.animals),
  MemoryCard(id: 15, imageAsset: '🐢', label: 'Tartaruga', theme: MemoryTheme.animals),
  MemoryCard(id: 16, imageAsset: '🦋', label: 'Borboleta', theme: MemoryTheme.animals),
];

/// Returns a shuffled list of [MemoryCard] pairs for [phaseNumber].
///
/// Each unique card appears exactly twice in the returned list so the caller
/// can lay them out as a matching grid directly.
List<MemoryCard> getCardsForPhase(int phaseNumber) {
  final phase = MemoryPhase.byNumber(phaseNumber);

  List<MemoryCard> pool;
  switch (phase.theme) {
    case MemoryTheme.fruits:
      pool = List.of(_fruitsPool);
    case MemoryTheme.animals:
      pool = List.of(_animalsPool);
    case MemoryTheme.mixed:
      pool = [..._fruitsPool, ..._animalsPool];
  }

  pool.shuffle();
  final unique = pool.take(phase.pairs).toList();

  // Duplicate each card to form pairs, then shuffle the full deck.
  final deck = [
    for (final card in unique) ...[
      card.copyWith(),
      card.copyWith(),
    ]
  ]..shuffle();

  return deck;
}
