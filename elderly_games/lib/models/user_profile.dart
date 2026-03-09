class UserProfile {
  final String id;
  final String name;
  final String avatarKey;
  final int totalPoints;
  final int currentPoints;
  final int dailyStreak;
  final DateTime? lastPlayedDate;
  final List<String> unlockedThemes;
  final Map<String, int> gameHighScores;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatarKey = 'default',
    this.totalPoints = 0,
    this.currentPoints = 0,
    this.dailyStreak = 0,
    this.lastPlayedDate,
    this.unlockedThemes = const [],
    this.gameHighScores = const {},
  });

  int get streakBonus {
    if (dailyStreak >= 30) return 50;
    if (dailyStreak >= 14) return 30;
    if (dailyStreak >= 7) return 20;
    if (dailyStreak >= 3) return 10;
    return 0;
  }

  UserProfile earnPoints(int amount) {
    assert(amount > 0);
    return copyWith(
      totalPoints: totalPoints + amount,
      currentPoints: currentPoints + amount,
    );
  }

  /// Returns a new profile with points deducted, or null if insufficient funds.
  (UserProfile?, bool) spendPoints(int amount) {
    assert(amount > 0);
    if (currentPoints < amount) return (null, false);
    return (copyWith(currentPoints: currentPoints - amount), true);
  }

  UserProfile updateDailyStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastPlayedDate == null) {
      return copyWith(dailyStreak: 1, lastPlayedDate: today);
    }

    final last = DateTime(
      lastPlayedDate!.year,
      lastPlayedDate!.month,
      lastPlayedDate!.day,
    );

    final diff = today.difference(last).inDays;

    if (diff == 0) {
      // Already played today, no change
      return this;
    } else if (diff == 1) {
      // Consecutive day
      return copyWith(dailyStreak: dailyStreak + 1, lastPlayedDate: today);
    } else {
      // Streak broken
      return copyWith(dailyStreak: 1, lastPlayedDate: today);
    }
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarKey,
    int? totalPoints,
    int? currentPoints,
    int? dailyStreak,
    DateTime? lastPlayedDate,
    List<String>? unlockedThemes,
    Map<String, int>? gameHighScores,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarKey: avatarKey ?? this.avatarKey,
      totalPoints: totalPoints ?? this.totalPoints,
      currentPoints: currentPoints ?? this.currentPoints,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      gameHighScores: gameHighScores ?? this.gameHighScores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarKey': avatarKey,
      'totalPoints': totalPoints,
      'currentPoints': currentPoints,
      'dailyStreak': dailyStreak,
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
      'unlockedThemes': unlockedThemes,
      'gameHighScores': gameHighScores,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarKey: json['avatarKey'] as String? ?? 'default',
      totalPoints: json['totalPoints'] as int? ?? 0,
      currentPoints: json['currentPoints'] as int? ?? 0,
      dailyStreak: json['dailyStreak'] as int? ?? 0,
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'] as String)
          : null,
      unlockedThemes: (json['unlockedThemes'] as List<dynamic>?)
              ?.cast<String>() ??
          const [],
      gameHighScores: (json['gameHighScores'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          const {},
    );
  }
}
