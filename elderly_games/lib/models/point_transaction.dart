enum TransactionType { earned, streakBonus, hintUsed, skipUsed, themeUnlock }

enum GameStatus { completed, quit, timeUp }

class PointTransaction {
  final String id;
  final String gameId;
  final TransactionType type;
  /// Positive = gain, negative = spend.
  final int amount;
  final DateTime timestamp;
  final String description;

  const PointTransaction({
    required this.id,
    required this.gameId,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'type': type.name,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      amount: json['amount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
    );
  }
}

class GameResult {
  final String gameId;
  final int score;
  final int pointsEarned;
  final int hintsUsed;
  final int skipsUsed;
  final Duration timePlayed;
  final GameStatus status;

  const GameResult({
    required this.gameId,
    required this.score,
    required this.pointsEarned,
    required this.hintsUsed,
    required this.skipsUsed,
    required this.timePlayed,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'score': score,
      'pointsEarned': pointsEarned,
      'hintsUsed': hintsUsed,
      'skipsUsed': skipsUsed,
      'timePlayedSeconds': timePlayed.inSeconds,
      'status': status.name,
    };
  }

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      gameId: json['gameId'] as String,
      score: json['score'] as int,
      pointsEarned: json['pointsEarned'] as int,
      hintsUsed: json['hintsUsed'] as int,
      skipsUsed: json['skipsUsed'] as int,
      timePlayed: Duration(seconds: json['timePlayedSeconds'] as int),
      status: GameStatus.values.byName(json['status'] as String),
    );
  }
}
