import 'dart:math';

import 'package:flutter/foundation.dart';

import 'word_search_data.dart';
import 'word_search_generator.dart';

class WordSearchGameState extends ChangeNotifier {
  // ── Puzzle ────────────────────────────────────────────────────────────────

  final WordSearchPuzzle puzzle;
  final String theme;

  // ── Progress ──────────────────────────────────────────────────────────────

  final Set<String> foundWords = {};
  int score = 0;
  int hintsUsed = 0;
  int skipsUsed = 0;
  final DateTime startTime = DateTime.now();

  // ── Selection ─────────────────────────────────────────────────────────────

  (int, int)? _dragStart;
  (int, int)? _dragCurrent;
  bool isSelecting = false;

  // ── Hint highlight ────────────────────────────────────────────────────────

  (int, int)? hintCell;

  // ── Constructor ───────────────────────────────────────────────────────────

  WordSearchGameState() : this._init(
    wordSearchThemes[Random().nextInt(wordSearchThemes.length)],
  );

  WordSearchGameState._init(String pickedTheme)
      : theme = pickedTheme,
        puzzle = WordSearchGenerator().generate(
          WordSearchDifficulty.easy.gridSize,
          WordSearchDifficulty.easy.wordCount,
          pickedTheme,
        );

  // ── Computed getters ──────────────────────────────────────────────────────

  /// The grid cells currently covered by the drag selection (in order).
  List<(int, int)> get selectedCells {
    if (_dragStart == null) return const [];
    final end = _dragCurrent ?? _dragStart!;
    return _cellsBetween(_dragStart!, end);
  }

  /// All grid cells belonging to already-found words.
  Set<(int, int)> get foundCells {
    final result = <(int, int)>{};
    for (final pw in puzzle.placedWords) {
      if (foundWords.contains(pw.word)) {
        for (final cell in pw.cells) { result.add(cell); }
      }
    }
    return result;
  }

  /// Returns `true` once every placed word has been found.
  bool get isComplete =>
      puzzle.placedWords.isNotEmpty &&
      puzzle.placedWords.every((pw) => foundWords.contains(pw.word));

  // ── Selection methods ─────────────────────────────────────────────────────

  /// Called when the player's finger first touches the grid.
  void startSelection(int row, int col) {
    _dragStart = (row, col);
    _dragCurrent = (row, col);
    isSelecting = true;
    notifyListeners();
  }

  /// Called continuously as the player's finger moves across the grid.
  void updateSelection(int row, int col) {
    if (!isSelecting || _dragStart == null) return;
    if (_dragCurrent == (row, col)) return; // no change
    _dragCurrent = (row, col);
    notifyListeners();
  }

  /// Called when the player lifts their finger.
  ///
  /// If the selected cells spell an unfound placed word, that word is marked
  /// as found and points are awarded.  Otherwise the selection is silently
  /// discarded.
  void endSelection() {
    final cells = selectedCells;

    if (cells.length >= 2) {
      final word = cells.map((c) => puzzle.grid[c.$1][c.$2]).join();

      PlacedWord? match;
      for (final pw in puzzle.placedWords) {
        if (pw.word == word && !foundWords.contains(pw.word)) {
          match = pw;
          break;
        }
      }

      if (match != null) {
        foundWords.add(match.word);
        score += match.word.length * 2; // 2 pts per letter
      }
    }

    _dragStart = null;
    _dragCurrent = null;
    isSelecting = false;
    notifyListeners();
  }

  // ── Power-ups ─────────────────────────────────────────────────────────────

  /// Briefly highlights the first letter of a random unfound word (max 3×).
  void useHint() {
    if (hintsUsed >= 3) return;
    final unfound = puzzle.placedWords
        .where((pw) => !foundWords.contains(pw.word))
        .toList();
    if (unfound.isEmpty) return;

    final target = unfound[Random().nextInt(unfound.length)];
    hintCell = target.cells.first;
    hintsUsed++;
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      hintCell = null;
      // Guard: ChangeNotifier is a no-op after all listeners detach.
      notifyListeners();
    });
  }

  /// Auto-completes a random unfound word without awarding points (max 1×).
  void useSkip() {
    if (skipsUsed >= 1) return;
    final unfound = puzzle.placedWords
        .where((pw) => !foundWords.contains(pw.word))
        .toList();
    if (unfound.isEmpty) return;

    final target = unfound[Random().nextInt(unfound.length)];
    foundWords.add(target.word);
    skipsUsed++;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns every (row, col) on the straight line from [from] to [to].
  ///
  /// Only horizontal (Δcol only), vertical (Δrow only), and true 45° diagonal
  /// (|Δrow| == |Δcol|) lines are valid.  Any other angle returns just [from]
  /// so the user's drag does not produce a nonsense selection.
  List<(int, int)> _cellsBetween((int, int) from, (int, int) to) {
    if (from == to) return [from];

    final dRow = to.$1 - from.$1;
    final dCol = to.$2 - from.$2;
    final absRow = dRow.abs();
    final absCol = dCol.abs();

    final isHorizontal = dRow == 0;
    final isVertical = dCol == 0;
    final isDiagonal = absRow == absCol;

    if (!isHorizontal && !isVertical && !isDiagonal) return [from];

    final stepRow = dRow == 0 ? 0 : (dRow > 0 ? 1 : -1);
    final stepCol = dCol == 0 ? 0 : (dCol > 0 ? 1 : -1);
    final steps = isHorizontal ? absCol : absRow;

    return List.generate(
      steps + 1,
      (i) => (from.$1 + i * stepRow, from.$2 + i * stepCol),
    );
  }
}
