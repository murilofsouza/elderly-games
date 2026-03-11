import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/user_profile.dart';
import '../models/game_info.dart';
import '../models/point_transaction.dart';
import 'storage_service.dart';

class PointsManager extends ChangeNotifier {
  final StorageService _storage;
  UserProfile _user;

  static const _uuid = Uuid();

  PointsManager(this._storage, this._user);

  // ── Getters ──────────────────────────────────────────────────────────────────

  UserProfile get user => _user;
  int get totalPoints => _user.totalPoints;
  int get currentPoints => _user.currentPoints;
  int get dailyStreak => _user.dailyStreak;
  int get streakBonus => _user.streakBonus;

  bool canAfford(int amount) => _user.currentPoints >= amount;

  // ── Game Result ───────────────────────────────────────────────────────────────

  /// Awards points for a completed game. Returns total points earned.
  Future<int> processGameResult(GameResult result, GameInfo info) async {
    if (result.status == GameStatus.quit) return 0;

    // Update streak first to get bonus
    _user = _user.updateDailyStreak();
    final bonus = _user.streakBonus;

    final baseEarned = result.pointsEarned;
    final bonusEarned = bonus > 0 ? (baseEarned * bonus ~/ 100) : 0;
    final total = baseEarned + bonusEarned;

    // Guard: skip point mutation and transaction recording when nothing was
    // earned (e.g. all answers wrong in number sequence).  Streak is still
    // persisted below so the daily streak always advances.
    if (total > 0) {
      _user = _user.earnPoints(total);

      await _recordTransaction(
        gameId: info.id,
        type: TransactionType.earned,
        amount: baseEarned,
        description: 'Pontos ganhos em ${info.title}',
      );

      if (bonusEarned > 0) {
        await _recordTransaction(
          gameId: info.id,
          type: TransactionType.streakBonus,
          amount: bonusEarned,
          description: 'Bônus de sequência de $dailyStreak dias',
        );
      }
    }

    // Update high score regardless of points earned.
    final currentBest = _user.gameHighScores[info.id] ?? 0;
    if (result.score > currentBest) {
      final updated = Map<String, int>.from(_user.gameHighScores)
        ..[info.id] = result.score;
      _user = _user.copyWith(gameHighScores: updated);
    }

    await _storage.saveUserProfile(_user);
    notifyListeners();
    return total;
  }

  // ── Spending ──────────────────────────────────────────────────────────────────

  Future<bool> useHint(GameInfo info) async {
    return _spendPoints(
      amount: info.hintCost,
      gameId: info.id,
      type: TransactionType.hintUsed,
      description: 'Dica usada em ${info.title}',
    );
  }

  Future<bool> useSkip(GameInfo info) async {
    return _spendPoints(
      amount: info.skipCost,
      gameId: info.id,
      type: TransactionType.skipUsed,
      description: 'Pular usado em ${info.title}',
    );
  }

  Future<bool> unlockTheme(String themeKey, int cost) async {
    final success = await _spendPoints(
      amount: cost,
      gameId: 'system',
      type: TransactionType.themeUnlock,
      description: 'Tema desbloqueado: $themeKey',
    );
    if (success) {
      final themes = List<String>.from(_user.unlockedThemes)..add(themeKey);
      _user = _user.copyWith(unlockedThemes: themes);
      await _storage.saveUserProfile(_user);
      notifyListeners();
    }
    return success;
  }

  // ── Profile Updates ───────────────────────────────────────────────────────────

  /// Replaces the entire user profile. Notifies before persisting so the UI
  /// updates immediately (optimistic update).
  Future<void> updateUser(UserProfile profile) async {
    _user = profile;
    notifyListeners();
    await _storage.saveUserProfile(_user);
  }

  /// Updates only the name. Notifies before persisting so the UI updates
  /// immediately without waiting for SharedPreferences to flush.
  Future<void> updateUserName(String name) async {
    _user = _user.copyWith(name: name);
    notifyListeners();
    await _storage.saveUserProfile(_user);
  }

  Future<void> updateAvatar(String avatarKey) async {
    _user = _user.copyWith(avatarKey: avatarKey);
    notifyListeners();
    await _storage.saveUserProfile(_user);
  }

  // ── Transactions ──────────────────────────────────────────────────────────────

  Future<List<PointTransaction>> getRecentTransactions({int limit = 20}) async {
    return _storage.loadTransactions().take(limit).toList();
  }

  // ── Private helpers ───────────────────────────────────────────────────────────

  Future<bool> _spendPoints({
    required int amount,
    required String gameId,
    required TransactionType type,
    required String description,
  }) async {
    final (updated, success) = _user.spendPoints(amount);
    if (!success || updated == null) return false;

    _user = updated;
    await _recordTransaction(
      gameId: gameId,
      type: type,
      amount: -amount,
      description: description,
    );
    await _storage.saveUserProfile(_user);
    notifyListeners();
    return true;
  }

  Future<void> _recordTransaction({
    required String gameId,
    required TransactionType type,
    required int amount,
    required String description,
  }) async {
    final transaction = PointTransaction(
      id: _uuid.v4(),
      gameId: gameId,
      type: type,
      amount: amount,
      timestamp: DateTime.now(),
      description: description,
    );
    await _storage.saveTransaction(transaction);
  }
}
