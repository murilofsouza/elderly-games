import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../models/game_info.dart';
import '../../models/point_transaction.dart';
import 'sequence_generator.dart';

// ── Answer feedback state ──────────────────────────────────────────────────────

enum AnswerStatus { none, correct, wrong, skipped }

// ── Game state ────────────────────────────────────────────────────────────────

class NumberSequenceState extends ChangeNotifier {
  // ── Config ──────────────────────────────────────────────────────────────────

  static const int _totalChallenges = 10;

  final GameDifficulty difficulty;

  // ── Challenges ──────────────────────────────────────────────────────────────

  final List<SequenceChallenge> _challenges;

  int _currentIndex = 0;

  // ── Per-challenge state ──────────────────────────────────────────────────────

  String _userInput = '';
  AnswerStatus _status = AnswerStatus.none;
  bool _showHint = false;

  // ── Aggregate state ─────────────────────────────────────────────────────────

  int _correctAnswers = 0;
  int _score = 0;
  int _hintsUsed = 0;
  int _skipsUsed = 0;
  bool _isGameOver = false;
  final DateTime _startTime = DateTime.now();

  // ── Constructor ─────────────────────────────────────────────────────────────

  NumberSequenceState({this.difficulty = GameDifficulty.easy})
      : _challenges = _buildChallenges(difficulty);

  static List<SequenceChallenge> _buildChallenges(GameDifficulty difficulty) {
    final rng = Random();
    final gen = SequenceGenerator();
    return List.generate(
      _totalChallenges,
      (_) => gen.generateChallenge(difficulty, rng),
    );
  }

  // ── Getters ─────────────────────────────────────────────────────────────────

  SequenceChallenge get currentChallenge => _challenges[_currentIndex];

  /// 1-based challenge counter (1–10).
  int get challengeNumber => _currentIndex + 1;

  int get totalChallenges => _totalChallenges;

  String get userInput => _userInput;

  AnswerStatus get status => _status;

  bool get isAnswered => _status != AnswerStatus.none;

  bool get isCorrect => _status == AnswerStatus.correct;

  bool get showHint => _showHint;

  int get correctAnswers => _correctAnswers;

  int get score => _score;

  int get hintsUsed => _hintsUsed;

  int get skipsUsed => _skipsUsed;

  bool get isGameOver => _isGameOver;

  // Points awarded per correct answer, scaled by difficulty.
  int get _pointsPerCorrect {
    return switch (difficulty) {
      GameDifficulty.easy   => 5,
      GameDifficulty.medium => 10,
      GameDifficulty.hard   => 15,
    };
  }

  // ── Input ────────────────────────────────────────────────────────────────────

  void appendDigit(String digit) {
    if (isAnswered) return;
    if (_userInput.length >= 4) return; // 4-digit cap is plenty
    _userInput += digit;
    notifyListeners();
  }

  void deleteLast() {
    if (isAnswered) return;
    if (_userInput.isEmpty) return;
    _userInput = _userInput.substring(0, _userInput.length - 1);
    notifyListeners();
  }

  // ── Answer submission ────────────────────────────────────────────────────────

  /// Checks [_userInput] against the current challenge's answer.
  ///
  /// Awards points on correct, then advances after a 1.5 s feedback delay.
  void submitAnswer() {
    if (isAnswered) return;
    if (_userInput.isEmpty) return;

    final parsed = int.tryParse(_userInput);
    if (parsed == null) return;

    if (parsed == currentChallenge.answer) {
      _score += _pointsPerCorrect;
      _correctAnswers++;
      _status = AnswerStatus.correct;
    } else {
      _status = AnswerStatus.wrong;
    }

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1500), () {
      _nextChallenge();
    });
  }

  // ── Power-ups ────────────────────────────────────────────────────────────────

  /// Reveals the rule for the current challenge for 3 seconds (max 3 uses).
  void useHint() {
    if (_hintsUsed >= 3) return;
    if (isAnswered) return;
    _hintsUsed++;
    _showHint = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      _showHint = false;
      notifyListeners();
    });
  }

  /// Reveals the answer without awarding points, then advances (max 1 use).
  void useSkip() {
    if (_skipsUsed >= 1) return;
    if (isAnswered) return;
    _skipsUsed++;
    _status = AnswerStatus.skipped;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1500), () {
      _nextChallenge();
    });
  }

  // ── Result snapshot ──────────────────────────────────────────────────────────

  GameResult getGameResult() {
    return GameResult(
      gameId:       'number_sequence',
      score:        _score,
      pointsEarned: _score,
      hintsUsed:    _hintsUsed,
      skipsUsed:    _skipsUsed,
      timePlayed:   DateTime.now().difference(_startTime),
      status:       _isGameOver ? GameStatus.completed : GameStatus.quit,
    );
  }

  // ── Internal ─────────────────────────────────────────────────────────────────

  void _nextChallenge() {
    if (_currentIndex >= _challenges.length - 1) {
      _isGameOver = true;
      notifyListeners();
      return;
    }
    _currentIndex++;
    _userInput = '';
    _status    = AnswerStatus.none;
    _showHint  = false;
    notifyListeners();
  }
}
