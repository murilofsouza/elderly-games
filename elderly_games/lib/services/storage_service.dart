import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../games/memory/memory_models.dart';
import '../models/user_profile.dart';
import '../models/point_transaction.dart';

class StorageService {
  static const _keyUserProfile = 'user_profile';
  static const _keyTransactions = 'point_transactions';
  static const _keyPurchasedGames = 'purchased_games';
  static const _keyOnboarding = 'onboarding_complete';
  static const _maxTransactions = 500;

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── User Profile ────────────────────────────────────────────────────────────

  bool get hasUser => _prefs.containsKey(_keyUserProfile);

  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));
  }

  UserProfile? loadUserProfile() {
    final raw = _prefs.getString(_keyUserProfile);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  // ── Transactions ─────────────────────────────────────────────────────────────

  Future<void> saveTransaction(PointTransaction transaction) async {
    final list = loadTransactions();
    list.insert(0, transaction);
    final trimmed = list.take(_maxTransactions).toList();
    await _prefs.setString(
      _keyTransactions,
      jsonEncode(trimmed.map((t) => t.toJson()).toList()),
    );
  }

  List<PointTransaction> loadTransactions() {
    final raw = _prefs.getString(_keyTransactions);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => PointTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Purchased Games ──────────────────────────────────────────────────────────

  Future<void> markGameAsPurchased(String gameId) async {
    final games = getPurchasedGames()..add(gameId);
    await _prefs.setStringList(_keyPurchasedGames, games.toList());
  }

  Set<String> getPurchasedGames() {
    return (_prefs.getStringList(_keyPurchasedGames) ?? []).toSet();
  }

  bool isGamePurchased(String gameId) => getPurchasedGames().contains(gameId);

  // ── Memory Game Progress ─────────────────────────────────────────────────────

  static const _keyMemoryProgress = 'memory_progress';

  Future<void> saveMemoryProgress(MemoryGameProgress progress) async {
    await _prefs.setString(
      _keyMemoryProgress,
      jsonEncode(progress.toJson()),
    );
  }

  MemoryGameProgress loadMemoryProgress() {
    final raw = _prefs.getString(_keyMemoryProgress);
    if (raw == null) return const MemoryGameProgress();
    return MemoryGameProgress.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  // ── Onboarding ───────────────────────────────────────────────────────────────

  bool get isOnboardingComplete => _prefs.getBool(_keyOnboarding) ?? false;

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_keyOnboarding, true);
  }
}
