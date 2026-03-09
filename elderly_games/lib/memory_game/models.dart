class PhaseResult {
  final int stars;
  final int bestTime;
  final int bestScore;
  final int errors;
  final DateTime playedAt;

  PhaseResult({
    required this.stars,
    required this.bestTime,
    required this.bestScore,
    required this.errors,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
        'stars': stars,
        'bestTime': bestTime,
        'bestScore': bestScore,
        'errors': errors,
        'playedAt': playedAt.toIso8601String(),
      };

  factory PhaseResult.fromJson(Map<String, dynamic> json) => PhaseResult(
        stars: json['stars'] as int,
        bestTime: json['bestTime'] as int,
        bestScore: json['bestScore'] as int,
        errors: json['errors'] as int,
        playedAt: DateTime.parse(json['playedAt'] as String),
      );
}

class MemoryGameProgress {
  int currentPhase;
  Map<int, PhaseResult> best;

  MemoryGameProgress({
    this.currentPhase = 1,
    Map<int, PhaseResult>? best,
  }) : best = best ?? {};
}

enum MemoryTheme { frutas, animais, misto }

class PhaseConfig {
  final int phase;
  final int pairs;
  final int rows;
  final int cols;
  final MemoryTheme theme;
  final int? timeLimitSeconds;
  final double multiplier;
  final bool hasPreview;

  const PhaseConfig({
    required this.phase,
    required this.pairs,
    required this.rows,
    required this.cols,
    required this.theme,
    this.timeLimitSeconds,
    required this.multiplier,
    required this.hasPreview,
  });
}

class MemoryCard {
  final String id;
  final String emoji;
  final String name;
  final MemoryTheme theme;

  const MemoryCard({
    required this.id,
    required this.emoji,
    required this.name,
    required this.theme,
  });
}

class GameCard {
  final int index;
  final MemoryCard card;
  bool isFlipped;
  bool isMatched;

  GameCard({
    required this.index,
    required this.card,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
