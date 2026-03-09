enum MemoryTheme { fruits, animals, mixed }

class MemoryCard {
  final int id;
  final String imageAsset;
  final String label;
  final MemoryTheme theme;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.imageAsset,
    required this.label,
    required this.theme,
    this.isFlipped = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({
    bool? isFlipped,
    bool? isMatched,
  }) =>
      MemoryCard(
        id: id,
        imageAsset: imageAsset,
        label: label,
        theme: theme,
        isFlipped: isFlipped ?? this.isFlipped,
        isMatched: isMatched ?? this.isMatched,
      );
}

class MemoryPhase {
  final int phaseNumber;
  final int pairs;
  final int columns;
  final int rows;
  final MemoryTheme theme;
  final int? timeLimitSeconds;
  final double multiplier;
  final bool hasPreview;

  const MemoryPhase({
    required this.phaseNumber,
    required this.pairs,
    required this.columns,
    required this.rows,
    required this.theme,
    this.timeLimitSeconds,
    required this.multiplier,
    required this.hasPreview,
  });

  static const List<MemoryPhase> all = [
    MemoryPhase(
      phaseNumber: 1,
      pairs: 4,
      columns: 4,
      rows: 2,
      theme: MemoryTheme.fruits,
      timeLimitSeconds: null,
      multiplier: 1.0,
      hasPreview: true,
    ),
    MemoryPhase(
      phaseNumber: 2,
      pairs: 5,
      columns: 5,
      rows: 2,
      theme: MemoryTheme.fruits,
      timeLimitSeconds: null,
      multiplier: 1.0,
      hasPreview: true,
    ),
    MemoryPhase(
      phaseNumber: 3,
      pairs: 6,
      columns: 4,
      rows: 3,
      theme: MemoryTheme.fruits,
      timeLimitSeconds: null,
      multiplier: 1.2,
      hasPreview: true,
    ),
    MemoryPhase(
      phaseNumber: 4,
      pairs: 6,
      columns: 4,
      rows: 3,
      theme: MemoryTheme.animals,
      timeLimitSeconds: 180,
      multiplier: 1.2,
      hasPreview: false,
    ),
    MemoryPhase(
      phaseNumber: 5,
      pairs: 8,
      columns: 4,
      rows: 4,
      theme: MemoryTheme.animals,
      timeLimitSeconds: 180,
      multiplier: 1.5,
      hasPreview: false,
    ),
    MemoryPhase(
      phaseNumber: 6,
      pairs: 8,
      columns: 4,
      rows: 4,
      theme: MemoryTheme.mixed,
      timeLimitSeconds: 150,
      multiplier: 1.5,
      hasPreview: false,
    ),
    MemoryPhase(
      phaseNumber: 7,
      pairs: 10,
      columns: 5,
      rows: 4,
      theme: MemoryTheme.mixed,
      timeLimitSeconds: 150,
      multiplier: 1.8,
      hasPreview: false,
    ),
    MemoryPhase(
      phaseNumber: 8,
      pairs: 12,
      columns: 6,
      rows: 4,
      theme: MemoryTheme.mixed,
      timeLimitSeconds: 120,
      multiplier: 2.0,
      hasPreview: false,
    ),
  ];

  static MemoryPhase byNumber(int phaseNumber) =>
      all.firstWhere((p) => p.phaseNumber == phaseNumber);
}

class PhaseResult {
  final int stars;
  final int bestTimeSeconds;
  final int bestScore;
  final int leastErrors;
  final DateTime playedAt;

  const PhaseResult({
    required this.stars,
    required this.bestTimeSeconds,
    required this.bestScore,
    required this.leastErrors,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
        'stars': stars,
        'bestTimeSeconds': bestTimeSeconds,
        'bestScore': bestScore,
        'leastErrors': leastErrors,
        'playedAt': playedAt.toIso8601String(),
      };

  factory PhaseResult.fromJson(Map<String, dynamic> json) => PhaseResult(
        stars: json['stars'] as int,
        bestTimeSeconds: json['bestTimeSeconds'] as int,
        bestScore: json['bestScore'] as int,
        leastErrors: json['leastErrors'] as int,
        playedAt: DateTime.parse(json['playedAt'] as String),
      );
}

class MemoryGameProgress {
  final int currentPhase;
  final Map<int, PhaseResult> bestResults;

  const MemoryGameProgress({
    this.currentPhase = 1,
    this.bestResults = const {},
  });

  MemoryGameProgress copyWith({
    int? currentPhase,
    Map<int, PhaseResult>? bestResults,
  }) =>
      MemoryGameProgress(
        currentPhase: currentPhase ?? this.currentPhase,
        bestResults: bestResults ?? this.bestResults,
      );

  Map<String, dynamic> toJson() => {
        'currentPhase': currentPhase,
        'bestResults': bestResults.map(
          (k, v) => MapEntry(k.toString(), v.toJson()),
        ),
      };

  factory MemoryGameProgress.fromJson(Map<String, dynamic> json) {
    final raw = json['bestResults'] as Map<String, dynamic>? ?? {};
    return MemoryGameProgress(
      currentPhase: json['currentPhase'] as int? ?? 1,
      bestResults: raw.map(
        (k, v) => MapEntry(
          int.parse(k),
          PhaseResult.fromJson(v as Map<String, dynamic>),
        ),
      ),
    );
  }
}
