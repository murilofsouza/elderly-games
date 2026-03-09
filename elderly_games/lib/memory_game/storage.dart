import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class MemoryGameStorage {
  static const _progressKey = 'memory_game_progress';
  static const _bestResultsKey = 'memory_game_best_results';

  static Future<MemoryGameProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPhase = prefs.getInt(_progressKey) ?? 1;
    final bestJson = prefs.getString(_bestResultsKey);

    Map<int, PhaseResult> best = {};
    if (bestJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(bestJson);
      for (final entry in decoded.entries) {
        best[int.parse(entry.key)] =
            PhaseResult.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    return MemoryGameProgress(currentPhase: currentPhase, best: best);
  }

  static Future<void> saveProgress(MemoryGameProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_progressKey, progress.currentPhase);

    final bestMap = <String, dynamic>{};
    for (final entry in progress.best.entries) {
      bestMap[entry.key.toString()] = entry.value.toJson();
    }
    await prefs.setString(_bestResultsKey, jsonEncode(bestMap));
  }

  static Future<void> updatePhaseResult(
      int phase, PhaseResult result, MemoryGameProgress progress) async {
    final existing = progress.best[phase];
    if (existing == null || result.bestScore > existing.bestScore) {
      progress.best[phase] = result;
    } else {
      // Update individual records
      progress.best[phase] = PhaseResult(
        stars: result.stars > existing.stars ? result.stars : existing.stars,
        bestTime: result.bestTime < existing.bestTime
            ? result.bestTime
            : existing.bestTime,
        bestScore: result.bestScore > existing.bestScore
            ? result.bestScore
            : existing.bestScore,
        errors:
            result.errors < existing.errors ? result.errors : existing.errors,
        playedAt: result.playedAt,
      );
    }

    // Unlock next phase
    if (phase >= progress.currentPhase && phase < 8) {
      progress.currentPhase = phase + 1;
    }

    await saveProgress(progress);
  }
}
