import '../models/game_info.dart';

class GameRegistry {
  static const List<GameInfo> allGames = [
    GameInfo(
      id: 'memory_cards',
      title: 'Jogo da Memoria',
      description: 'Encontre os pares de cartas e treine sua memoria.',
      iconAsset: 'assets/icons/memory_cards.png',
      category: GameCategory.memory,
      isFree: true,
      price: 0,
      basePoints: 10,
      hintCost: 5,
      skipCost: 15,
      availableDifficulties: [
        GameDifficulty.easy,
        GameDifficulty.medium,
        GameDifficulty.hard,
      ],
      routeName: '/memory_cards',
    ),
    GameInfo(
      id: 'word_search',
      title: 'Caca-Palavras',
      description: 'Encontre as palavras escondidas na grade de letras.',
      iconAsset: 'assets/icons/word_search.png',
      category: GameCategory.words,
      isFree: true,
      price: 0,
      basePoints: 15,
      hintCost: 8,
      skipCost: 20,
      availableDifficulties: [
        GameDifficulty.easy,
        GameDifficulty.medium,
        GameDifficulty.hard,
      ],
      routeName: '/word_search',
    ),
    GameInfo(
      id: 'number_sequence',
      title: 'Sequencia de Numeros',
      description: 'Complete a sequencia numerica corretamente.',
      iconAsset: 'assets/icons/number_sequence.png',
      category: GameCategory.numbers,
      isFree: true,
      price: 0,
      basePoints: 12,
      hintCost: 6,
      skipCost: 18,
      availableDifficulties: [
        GameDifficulty.easy,
        GameDifficulty.medium,
        GameDifficulty.hard,
      ],
      routeName: '/number_sequence',
    ),
    GameInfo(
      id: 'trivia_quiz',
      title: 'Quiz de Perguntas',
      description: 'Responda perguntas de cultura geral e conhecimento.',
      iconAsset: 'assets/icons/trivia_quiz.png',
      category: GameCategory.trivia,
      isFree: false,
      productId: 'com.elderlygames.trivia_quiz',
      price: 4.99,
      basePoints: 20,
      availableDifficulties: [
        GameDifficulty.easy,
        GameDifficulty.medium,
        GameDifficulty.hard,
      ],
      routeName: '/trivia_quiz',
    ),
    GameInfo(
      id: 'puzzle_slide',
      title: 'Quebra-Cabeca Deslizante',
      description: 'Monte a imagem movendo as pecas ate o lugar certo.',
      iconAsset: 'assets/icons/puzzle_slide.png',
      category: GameCategory.puzzle,
      isFree: false,
      productId: 'com.elderlygames.puzzle_slide',
      price: 3.99,
      basePoints: 18,
      availableDifficulties: [
        GameDifficulty.easy,
        GameDifficulty.medium,
        GameDifficulty.hard,
      ],
      routeName: '/puzzle_slide',
    ),
  ];

  static List<GameInfo> get freeGames =>
      allGames.where((g) => g.isFree).toList();

  static List<GameInfo> get paidGames =>
      allGames.where((g) => !g.isFree).toList();

  static GameInfo? getById(String id) {
    try {
      return allGames.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<GameInfo> getByCategory(GameCategory category) =>
      allGames.where((g) => g.category == category).toList();
}
