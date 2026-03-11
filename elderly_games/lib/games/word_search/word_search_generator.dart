import 'dart:math';

import 'word_search_data.dart';

// ── Direction ─────────────────────────────────────────────────────────────────

enum WordDirection {
  horizontal,    // left → right
  vertical,      // top  → bottom
  diagonalDown,  // top-left → bottom-right
}

// ── Data classes ──────────────────────────────────────────────────────────────

/// A word successfully placed in the grid.
class PlacedWord {
  final String word;
  final int startRow;
  final int startCol;
  final WordDirection direction;

  const PlacedWord({
    required this.word,
    required this.startRow,
    required this.startCol,
    required this.direction,
  });

  /// Row/column index of every letter in this word (in order).
  List<(int, int)> get cells {
    return List.generate(word.length, (i) {
      switch (direction) {
        case WordDirection.horizontal:
          return (startRow, startCol + i);
        case WordDirection.vertical:
          return (startRow + i, startCol);
        case WordDirection.diagonalDown:
          return (startRow + i, startCol + i);
      }
    });
  }

  @override
  String toString() =>
      'PlacedWord($word @ [$startRow,$startCol] $direction)';
}

/// The finished puzzle: a filled letter grid and the list of hidden words.
class WordSearchPuzzle {
  /// [grid][row][col] — every cell is a single uppercase letter.
  final List<List<String>> grid;

  /// Words that were successfully placed in the grid.
  final List<PlacedWord> placedWords;

  const WordSearchPuzzle({required this.grid, required this.placedWords});

  int get gridSize => grid.length;
}

// ── Difficulty preset ─────────────────────────────────────────────────────────

class WordSearchDifficulty {
  final String label;
  final int gridSize;
  final int wordCount;

  const WordSearchDifficulty._({
    required this.label,
    required this.gridSize,
    required this.wordCount,
  });

  static const easy   = WordSearchDifficulty._(label: 'Fácil',  gridSize:  8, wordCount:  5);
  static const medium = WordSearchDifficulty._(label: 'Médio',  gridSize: 10, wordCount:  7);
  static const hard   = WordSearchDifficulty._(label: 'Difícil', gridSize: 12, wordCount: 10);

  static const List<WordSearchDifficulty> all = [easy, medium, hard];
}

// ── Generator ─────────────────────────────────────────────────────────────────

class WordSearchGenerator {
  static const _maxPlacementAttempts = 100;
  static const _fillLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// Generates a [WordSearchPuzzle] for [theme] with the given grid dimensions.
  ///
  /// Words longer than [gridSize] are silently excluded because they cannot
  /// fit in any direction. If fewer than [wordCount] words can be placed the
  /// puzzle is returned with however many fitted.
  WordSearchPuzzle generate(int gridSize, int wordCount, String theme) {
    final rng = Random();

    // 1. Pick candidate words ─────────────────────────────────────────────────
    final candidates = wordsForTheme(theme, maxLength: gridSize)..shuffle(rng);
    final selected = candidates.take(wordCount).toList();

    // 2. Initialise an empty grid ─────────────────────────────────────────────
    final grid = List.generate(
      gridSize,
      (_) => List<String>.filled(gridSize, ''),
    );

    // 3. Place words ──────────────────────────────────────────────────────────
    final placed = <PlacedWord>[];
    for (final word in selected) {
      final pw = _attemptPlace(grid, gridSize, word, rng);
      if (pw != null) placed.add(pw);
    }

    // 4. Fill remaining empty cells with random letters ────────────────────────
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c].isEmpty) {
          grid[r][c] = _randomLetter(rng);
        }
      }
    }

    return WordSearchPuzzle(grid: grid, placedWords: placed);
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  /// Tries up to [_maxPlacementAttempts] random positions/directions.
  /// Returns the [PlacedWord] on success, or `null` if the word couldn't fit.
  PlacedWord? _attemptPlace(
    List<List<String>> grid,
    int gridSize,
    String word,
    Random rng,
  ) {
    for (int attempt = 0; attempt < _maxPlacementAttempts; attempt++) {
      final dir = WordDirection.values[rng.nextInt(WordDirection.values.length)];
      final startRow = rng.nextInt(gridSize);
      final startCol = rng.nextInt(gridSize);

      if (!_fitsInGrid(gridSize, word.length, startRow, startCol, dir)) {
        continue;
      }

      if (_canPlace(grid, word, startRow, startCol, dir)) {
        _commitPlace(grid, word, startRow, startCol, dir);
        return PlacedWord(
          word: word,
          startRow: startRow,
          startCol: startCol,
          direction: dir,
        );
      }
    }
    return null;
  }

  /// Returns `true` when all cells along the path are either empty or already
  /// hold the correct letter (allowing valid word intersections).
  bool _canPlace(
    List<List<String>> grid,
    String word,
    int startRow,
    int startCol,
    WordDirection dir,
  ) {
    for (int i = 0; i < word.length; i++) {
      final (r, c) = _cell(startRow, startCol, dir, i);
      final existing = grid[r][c];
      if (existing.isNotEmpty && existing != word[i]) return false;
    }
    return true;
  }

  /// Writes the word into the grid (call only after [_canPlace] returns true).
  void _commitPlace(
    List<List<String>> grid,
    String word,
    int startRow,
    int startCol,
    WordDirection dir,
  ) {
    for (int i = 0; i < word.length; i++) {
      final (r, c) = _cell(startRow, startCol, dir, i);
      grid[r][c] = word[i];
    }
  }

  /// Whether the word at this origin and direction stays within the grid.
  bool _fitsInGrid(
    int gridSize,
    int wordLen,
    int startRow,
    int startCol,
    WordDirection dir,
  ) {
    switch (dir) {
      case WordDirection.horizontal:
        return startCol + wordLen <= gridSize;
      case WordDirection.vertical:
        return startRow + wordLen <= gridSize;
      case WordDirection.diagonalDown:
        return startRow + wordLen <= gridSize && startCol + wordLen <= gridSize;
    }
  }

  /// (row, col) of the i-th letter given an origin and direction.
  (int, int) _cell(int startRow, int startCol, WordDirection dir, int i) {
    switch (dir) {
      case WordDirection.horizontal:
        return (startRow, startCol + i);
      case WordDirection.vertical:
        return (startRow + i, startCol);
      case WordDirection.diagonalDown:
        return (startRow + i, startCol + i);
    }
  }

  String _randomLetter(Random rng) =>
      _fillLetters[rng.nextInt(_fillLetters.length)];
}
