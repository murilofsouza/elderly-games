import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../models/point_transaction.dart';
import 'memory_assets.dart';
import 'memory_models.dart';

const String _kMemoryGameId = 'memory_game';

/// Base points awarded per matched pair (before multiplier and combo).
const int _kBasePoints = 20;

/// Extra points added per combo level above 1.
const int _kComboBonus = 5;

class MemoryGameState extends ChangeNotifier {
  // ── Phase config ─────────────────────────────────────────────────────────────

  final MemoryPhase phase;

  // ── Grid ─────────────────────────────────────────────────────────────────────

  late List<MemoryCard> cards;

  // ── Flip tracking ────────────────────────────────────────────────────────────

  int? firstFlipped;
  int? secondFlipped;

  // ── Progress ─────────────────────────────────────────────────────────────────

  int matchedPairs = 0;
  late final int totalPairs;
  int errors = 0;
  int currentCombo = 0;
  int maxCombo = 0;
  int score = 0;

  // ── Power-ups ────────────────────────────────────────────────────────────────

  int hintsUsed = 0;
  int skipsUsed = 0;

  // ── Flow control ─────────────────────────────────────────────────────────────

  bool isProcessing = false;
  bool isPreviewMode = false;
  int? timeRemainingSeconds;
  bool isGameOver = false;
  DateTime? gameStartTime;

  // ── Internals ────────────────────────────────────────────────────────────────

  Timer? _countdownTimer;

  // ── Constructor ──────────────────────────────────────────────────────────────

  MemoryGameState({required int phaseNumber})
      : phase = MemoryPhase.byNumber(phaseNumber) {
    cards = getCardsForPhase(phaseNumber);
    totalPairs = phase.pairs;

    if (phase.timeLimitSeconds != null) {
      timeRemainingSeconds = phase.timeLimitSeconds;
    }

    if (phase.hasPreview) {
      startPreview();
    } else {
      _markGameStarted();
    }
  }

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Flip the card at [index].
  ///
  /// Guards against: game locked states, already-flipped cards, and tapping
  /// the same card as [firstFlipped].
  void flipCard(int index) {
    if (isProcessing || isGameOver || isPreviewMode) return;
    final card = cards[index];
    if (card.isFlipped || card.isMatched) return;

    card.isFlipped = true;
    notifyListeners();

    if (firstFlipped == null) {
      firstFlipped = index;
      return;
    }

    // Second card — begin resolution after animation settles.
    secondFlipped = index;
    isProcessing = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1200), _resolveFlip);
  }

  /// Returns the indices `[a, b]` of an unmatched pair for hint animation, or
  /// `null` when the hint limit is reached or no unmatched pair exists.
  List<int>? useHint() {
    if (hintsUsed >= 3) return null;
    final pair = _findUnmatchedPair();
    if (pair == null) return null;
    hintsUsed++;
    notifyListeners();
    return pair;
  }

  /// Auto-matches one unmatched pair without awarding points.
  ///
  /// Returns `false` when the skip limit is reached or there is nothing left
  /// to skip.
  bool useSkip() {
    if (skipsUsed >= 1) return false;
    final pair = _findUnmatchedPair();
    if (pair == null) return false;

    final a = pair[0];
    final b = pair[1];

    cards[a]
      ..isFlipped = true
      ..isMatched = true;
    cards[b]
      ..isFlipped = true
      ..isMatched = true;

    matchedPairs++;
    skipsUsed++;

    // Clear any in-progress flip so the board isn't left in a locked state.
    firstFlipped = null;
    secondFlipped = null;
    isProcessing = false;

    _checkWin();
    notifyListeners();
    return true;
  }

  /// Reveals all cards for 3 seconds then hides them. Only meaningful for
  /// phases 1-3 (`phase.hasPreview == true`).
  void startPreview() {
    isPreviewMode = true;
    for (final c in cards) {
      c.isFlipped = true;
    }
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      for (final c in cards) {
        c.isFlipped = false;
      }
      isPreviewMode = false;
      _markGameStarted();
      notifyListeners();
    });
  }

  /// Starts the countdown timer if the phase has a time limit.
  ///
  /// Calling this more than once cancels the previous timer first, making it
  /// safe to restart.
  void startTimer() {
    if (phase.timeLimitSeconds == null) return;
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeRemainingSeconds == null || timeRemainingSeconds! <= 0) {
        _countdownTimer?.cancel();
        _triggerTimeUp();
        return;
      }

      timeRemainingSeconds = timeRemainingSeconds! - 1;
      notifyListeners();

      if (timeRemainingSeconds! <= 0) {
        _countdownTimer?.cancel();
        _triggerTimeUp();
      }
    });
  }

  /// Returns the star rating for the current (or final) game state.
  ///
  /// | Condition              | Stars |
  /// |------------------------|-------|
  /// | Incomplete / timed-out | 0     |
  /// | Completed, 0 errors    | 3     |
  /// | Completed, 1-2 errors  | 2     |
  /// | Completed, 3+ errors   | 1     |
  int calculateStars() {
    if (!isGameOver) return 0;
    if (matchedPairs < totalPairs) return 0; // timed out
    if (errors == 0) return 3;
    if (errors <= 2) return 2;
    return 1;
  }

  /// Builds a [GameResult] for handing off to [PointsManager.processGameResult].
  GameResult getGameResult() {
    final elapsed = gameStartTime != null
        ? DateTime.now().difference(gameStartTime!)
        : Duration.zero;

    final status = (isGameOver && matchedPairs < totalPairs)
        ? GameStatus.timeUp
        : GameStatus.completed;

    return GameResult(
      gameId: _kMemoryGameId,
      score: score,
      pointsEarned: score,
      hintsUsed: hintsUsed,
      skipsUsed: skipsUsed,
      timePlayed: elapsed,
      status: status,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  /// Records [gameStartTime] and starts the countdown (if any).
  void _markGameStarted() {
    gameStartTime = DateTime.now();
    startTimer();
  }

  void _resolveFlip() {
    final a = firstFlipped!;
    final b = secondFlipped!;

    if (cards[a].id == cards[b].id) {
      // ── Match ──
      cards[a].isMatched = true;
      cards[b].isMatched = true;
      matchedPairs++;

      currentCombo++;
      if (currentCombo > maxCombo) maxCombo = currentCombo;

      score += _calcPairScore();
      _checkWin();
    } else {
      // ── No match ──
      cards[a].isFlipped = false;
      cards[b].isFlipped = false;
      errors++;
      currentCombo = 0;
    }

    firstFlipped = null;
    secondFlipped = null;
    isProcessing = false;

    notifyListeners();
  }

  /// Points for a matched pair: base × multiplier + combo bonus.
  ///
  /// The combo bonus is 0 for the first match in a streak, then grows by
  /// [_kComboBonus] per additional consecutive match.
  int _calcPairScore() {
    final base = _kBasePoints * phase.multiplier;
    final bonus = (currentCombo - 1) * _kComboBonus; // currentCombo already incremented
    return (base + bonus).round();
  }

  void _checkWin() {
    if (matchedPairs >= totalPairs) {
      isGameOver = true;
      _countdownTimer?.cancel();
    }
  }

  void _triggerTimeUp() {
    if (isGameOver) return;
    isGameOver = true;
    notifyListeners();
  }

  /// Finds two cards that share the same [MemoryCard.id] and are not yet
  /// matched. Returns `null` when every pair has been matched.
  List<int>? _findUnmatchedPair() {
    final firstSeen = <int, int>{}; // card.id → first unmatched index
    for (int i = 0; i < cards.length; i++) {
      if (cards[i].isMatched) continue;
      final id = cards[i].id;
      if (firstSeen.containsKey(id)) {
        return [firstSeen[id]!, i];
      }
      firstSeen[id] = i;
    }
    return null;
  }
}
