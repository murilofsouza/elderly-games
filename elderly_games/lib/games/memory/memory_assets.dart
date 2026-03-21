import 'package:flutter/material.dart';

import 'memory_models.dart';

// Intuitive color for each card pair — used as the accessibility border.
// Colors match the real-world item so users learn the association naturally.
const Map<int, Color> cardPairColors = {
  1:  Color(0xFFEF9A9A), // Maçã      — vermelho pastel
  2:  Color(0xFFFFF176), // Banana    — amarelo pastel
  3:  Color(0xFFCE93D8), // Uva       — lilás pastel
  4:  Color(0xFFFFCC80), // Laranja   — pêssego claro
  5:  Color(0xFFF48FB1), // Morango   — rosa pastel
  6:  Color(0xFFA5D6A7), // Melancia  — verde pastel
  7:  Color(0xFFE6EE9C), // Abacaxi   — verde-limão pastel
  8:  Color(0xFF80DEEA), // Pêssego   — ciano pastel
  9:  Color(0xFFFFD54F), // Gato      — âmbar pastel
  10: Color(0xFFBCAAA4), // Cachorro  — bege/marrom pastel
  11: Color(0xFF81D4FA), // Pássaro   — azul céu pastel
  12: Color(0xFF80CBC4), // Peixe     — verde-água pastel
  13: Color(0xFF9FA8DA), // Cavalo    — índigo pastel
  14: Color(0xFFF8BBD9), // Coelho    — rosa bebê
  15: Color(0xFFC5E1A5), // Tartaruga — verde-sálvia pastel
  16: Color(0xFFB39DDB), // Borboleta — lavanda pastel
};

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
