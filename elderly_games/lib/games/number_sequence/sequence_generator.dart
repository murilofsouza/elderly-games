import 'dart:math';

import '../../models/game_info.dart';

// ── Data class ────────────────────────────────────────────────────────────────

class SequenceChallenge {
  /// The 5-element sequence; the slot at [missingIndex] is `null`.
  final List<int?> numbers;

  /// Index (0-based) of the missing number.
  final int missingIndex;

  /// Correct value for the missing slot.
  final int answer;

  /// Short rule string shown as a hint (e.g. '+2', '×3', 'Fibonacci').
  final String rule;

  final GameDifficulty difficulty;

  const SequenceChallenge({
    required this.numbers,
    required this.missingIndex,
    required this.answer,
    required this.rule,
    required this.difficulty,
  });
}

// ── Generator ─────────────────────────────────────────────────────────────────

class SequenceGenerator {
  // ── Template pools ── (full 5-element list, rule hint) ──────────────────────
  //
  // Each entry is a (List<int>, String) record.
  // Missing position is chosen at runtime from [1,2,3] so the same
  // full sequence can produce three distinct challenges.

  // Easy: linear arithmetic (+2, +3, +5, +10) — 20 templates
  static final _easy = <(List<int>, String)>[
    ([2, 4, 6, 8, 10],      '+2'),
    ([4, 6, 8, 10, 12],     '+2'),
    ([6, 8, 10, 12, 14],    '+2'),
    ([10, 12, 14, 16, 18],  '+2'),
    ([1, 3, 5, 7, 9],       '+2'),
    ([3, 6, 9, 12, 15],     '+3'),
    ([6, 9, 12, 15, 18],    '+3'),
    ([9, 12, 15, 18, 21],   '+3'),
    ([12, 15, 18, 21, 24],  '+3'),
    ([15, 18, 21, 24, 27],  '+3'),
    ([5, 10, 15, 20, 25],   '+5'),
    ([10, 15, 20, 25, 30],  '+5'),
    ([15, 20, 25, 30, 35],  '+5'),
    ([2, 7, 12, 17, 22],    '+5'),
    ([20, 25, 30, 35, 40],  '+5'),
    ([10, 20, 30, 40, 50],  '+10'),
    ([20, 30, 40, 50, 60],  '+10'),
    ([5, 15, 25, 35, 45],   '+10'),
    ([30, 40, 50, 60, 70],  '+10'),
    ([15, 25, 35, 45, 55],  '+10'),
  ];

  // Medium: multiplicative and alternating-step — 20 templates
  //
  // Alternating diffs: '+a e +b' means diffs cycle a, b, a, b.
  //   e.g. '+3 e +5' from start s: [s, s+3, s+8, s+11, s+16]
  static final _medium = <(List<int>, String)>[
    // ×2
    ([1, 2, 4, 8, 16],    '×2'),
    ([2, 4, 8, 16, 32],   '×2'),
    ([3, 6, 12, 24, 48],  '×2'),
    ([4, 8, 16, 32, 64],  '×2'),
    ([5, 10, 20, 40, 80], '×2'),
    // ×3
    ([1, 3, 9, 27, 81],   '×3'),
    ([2, 6, 18, 54, 162], '×3'),
    ([3, 9, 27, 81, 243], '×3'),
    // alternating +3 +5 → diffs: 3,5,3,5
    ([1, 4, 9, 12, 17],   '+3 e +5'),
    ([2, 5, 10, 13, 18],  '+3 e +5'),
    ([3, 6, 11, 14, 19],  '+3 e +5'),
    // alternating +2 +4 → diffs: 2,4,2,4
    ([1, 3, 7, 9, 13],    '+2 e +4'),
    ([2, 4, 8, 10, 14],   '+2 e +4'),
    ([5, 7, 11, 13, 17],  '+2 e +4'),
    // alternating +5 +3 → diffs: 5,3,5,3
    ([1, 6, 9, 14, 17],   '+5 e +3'),
    ([2, 7, 10, 15, 18],  '+5 e +3'),
    ([4, 9, 12, 17, 20],  '+5 e +3'),
    // alternating +10 +5 → diffs: 10,5,10,5
    ([5, 15, 20, 30, 35],   '+10 e +5'),
    ([10, 20, 25, 35, 40],  '+10 e +5'),
    ([15, 25, 30, 40, 45],  '+10 e +5'),
  ];

  // Hard: squares, triangular, Fibonacci, cubes — 17 templates (≥15)
  static final _hard = <(List<int>, String)>[
    // n² — consecutive squares
    ([1, 4, 9, 16, 25],    'n²'),
    ([4, 9, 16, 25, 36],   'n²'),
    ([9, 16, 25, 36, 49],  'n²'),
    ([16, 25, 36, 49, 64], 'n²'),
    ([25, 36, 49, 64, 81], 'n²'),
    // triangular: T(n) = n(n+1)/2 → 1,3,6,10,15,21,28,36,45,55
    ([1, 3, 6, 10, 15],    'triangular'),
    ([3, 6, 10, 15, 21],   'triangular'),
    ([6, 10, 15, 21, 28],  'triangular'),
    ([10, 15, 21, 28, 36], 'triangular'),
    ([15, 21, 28, 36, 45], 'triangular'),
    // Fibonacci-like: each = sum of two previous
    ([1, 1, 2, 3, 5],      'Fibonacci'),
    ([1, 2, 3, 5, 8],      'Fibonacci'),
    ([2, 3, 5, 8, 13],     'Fibonacci'),
    ([3, 5, 8, 13, 21],    'Fibonacci'),
    ([5, 8, 13, 21, 34],   'Fibonacci'),
    // n³ — consecutive cubes
    ([1, 8, 27, 64, 125],    'n³'),
    ([8, 27, 64, 125, 216],  'n³'),
  ];

  // Missing index drawn from positions 1, 2, 3 (never first or last)
  // so there is always at least one known number on each side.
  static const _missingPositions = [1, 2, 3];

  /// Returns a random [SequenceChallenge] for the given [difficulty].
  SequenceChallenge generateChallenge(GameDifficulty difficulty, Random rng) {
    final pool = switch (difficulty) {
      GameDifficulty.easy   => _easy,
      GameDifficulty.medium => _medium,
      GameDifficulty.hard   => _hard,
    };

    final template    = pool[rng.nextInt(pool.length)];
    final full        = template.$1;
    final rule        = template.$2;
    final missingIdx  = _missingPositions[rng.nextInt(_missingPositions.length)];
    final answer      = full[missingIdx];

    final numbers = List<int?>.of(full.cast<int?>());
    numbers[missingIdx] = null;

    return SequenceChallenge(
      numbers:      numbers,
      missingIndex: missingIdx,
      answer:       answer,
      rule:         rule,
      difficulty:   difficulty,
    );
  }
}
