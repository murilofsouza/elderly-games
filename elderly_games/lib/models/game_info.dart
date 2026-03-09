enum GameCategory { memory, words, puzzle, numbers, trivia }

enum GameDifficulty { easy, medium, hard }

class GameInfo {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final GameCategory category;
  final bool isFree;
  final String? productId;
  final double price;
  final int basePoints;
  final int hintCost;
  final int skipCost;
  final List<GameDifficulty> availableDifficulties;
  final String routeName;

  const GameInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.category,
    required this.isFree,
    this.productId,
    required this.price,
    required this.basePoints,
    this.hintCost = 10,
    this.skipCost = 25,
    required this.availableDifficulties,
    required this.routeName,
  });

  int pointsForDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return basePoints;
      case GameDifficulty.medium:
        return (basePoints * 1.5).round();
      case GameDifficulty.hard:
        return basePoints * 2;
    }
  }

  static String categoryLabel(GameCategory category) {
    switch (category) {
      case GameCategory.memory:
        return 'Memoria';
      case GameCategory.words:
        return 'Palavras';
      case GameCategory.puzzle:
        return 'Quebra-Cabeca';
      case GameCategory.numbers:
        return 'Numeros';
      case GameCategory.trivia:
        return 'Perguntas';
    }
  }

  static String difficultyLabel(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'Facil';
      case GameDifficulty.medium:
        return 'Medio';
      case GameDifficulty.hard:
        return 'Dificil';
    }
  }
}
