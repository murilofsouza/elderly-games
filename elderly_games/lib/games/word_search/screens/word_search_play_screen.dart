import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/game_info.dart';
import '../../../services/game_registry.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/game_action_bar.dart';
import '../../../widgets/game_dialogs.dart';
import '../word_search_game_state.dart';
import 'word_search_result_screen.dart';

class WordSearchPlayScreen extends StatefulWidget {
  const WordSearchPlayScreen({super.key});

  @override
  State<WordSearchPlayScreen> createState() => _WordSearchPlayScreenState();
}

class _WordSearchPlayScreenState extends State<WordSearchPlayScreen> {
  late final WordSearchGameState _gameState;
  late final GameInfo _gameInfo;
  bool _gameOverHandled = false;

  @override
  void initState() {
    super.initState();
    _gameState = WordSearchGameState();
    _gameInfo = GameRegistry.getById('word_search')!;
    _gameState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (_gameState.isComplete && !_gameOverHandled) {
      _gameOverHandled = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _handleComplete());
    }
    if (mounted) setState(() {});
  }

  void _handleComplete() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WordSearchResultScreen(gameState: _gameState),
      ),
    );
  }

  // Called after GameActionBar already deducted points from PointsManager.
  void _onHintUsed() => _gameState.useHint();
  void _onSkipUsed() => _gameState.useSkip();

  Future<bool> _confirmExit() async {
    if (_gameState.isComplete) return true;
    return showExitGameDialog(context);
  }

  @override
  void dispose() {
    _gameState.removeListener(_onStateChanged);
    _gameState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WordSearchGameState>.value(
      value: _gameState,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final exit = await _confirmExit();
          if (exit && context.mounted) Navigator.pop(context);
        },
        child: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: _WordSearchAppBar(
            onBack: () async {
              final exit = await _confirmExit();
              if (exit && context.mounted) Navigator.pop(context);
            },
          ),
          body: Column(
            children: [
              // ── Theme label ──────────────────────────────────────────────
              _ThemeLabel(theme: _gameState.theme),

              // ── Letter grid ──────────────────────────────────────────────
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _WordGrid(gameInfo: _gameInfo),
                    ),
                  ),
                ),
              ),

              // ── Word chips ───────────────────────────────────────────────
              const _WordChips(),

              // ── Action bar ───────────────────────────────────────────────
              GameActionBar(
                game: _gameInfo,
                onHintUsed: _onHintUsed,
                onSkipUsed: _onSkipUsed,
                canSkip: _gameState.skipsUsed < 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────

class _WordSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onBack;

  const _WordSearchAppBar({required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(AppTheme.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WordSearchGameState>();
    final found = state.foundWords.length;
    final total = state.puzzle.placedWords.length;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Voltar',
        onPressed: onBack,
      ),
      title: const Text('Caça-Palavras'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded,
                  size: 20, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                '$found/$total',
                style: const TextStyle(
                  fontSize: AppTheme.fontTitle,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Theme label ───────────────────────────────────────────────────────────────

class _ThemeLabel extends StatelessWidget {
  final String theme;

  const _ThemeLabel({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      color: AppTheme.primaryColor.withValues(alpha: 0.08),
      child: Row(
        children: [
          const Icon(Icons.label_rounded,
              size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            'Tema: $theme',
            style: const TextStyle(
              fontSize: AppTheme.fontBody,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Letter grid with GestureDetector ─────────────────────────────────────────

class _WordGrid extends StatelessWidget {
  final GameInfo gameInfo;

  const _WordGrid({required this.gameInfo});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WordSearchGameState>();
    final gridSize = state.puzzle.gridSize;
    final selectedSet = state.selectedCells.toSet();
    final foundSet = state.foundCells;
    final hintCell = state.hintCell;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / gridSize;

        return GestureDetector(
          onPanStart: (d) {
            final col =
                (d.localPosition.dx / cellSize).floor().clamp(0, gridSize - 1);
            final row =
                (d.localPosition.dy / cellSize).floor().clamp(0, gridSize - 1);
            state.startSelection(row, col);
          },
          onPanUpdate: (d) {
            final col =
                (d.localPosition.dx / cellSize).floor().clamp(0, gridSize - 1);
            final row =
                (d.localPosition.dy / cellSize).floor().clamp(0, gridSize - 1);
            state.updateSelection(row, col);
          },
          onPanEnd: (_) => state.endSelection(),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: List.generate(gridSize, (r) {
                  return Expanded(
                    child: Row(
                      children: List.generate(gridSize, (c) {
                        final isSelected = selectedSet.contains((r, c));
                        final isFound = foundSet.contains((r, c));
                        final isHint = hintCell == (r, c);

                        return Expanded(
                          child: _CellWidget(
                            letter: state.puzzle.grid[r][c],
                            isSelected: isSelected,
                            isFound: isFound,
                            isHint: isHint,
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Single grid cell ──────────────────────────────────────────────────────────

class _CellWidget extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final bool isFound;
  final bool isHint;

  const _CellWidget({
    required this.letter,
    required this.isSelected,
    required this.isFound,
    required this.isHint,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;

    if (isFound) {
      bg = AppTheme.successColor;
      fg = Colors.white;
    } else if (isSelected) {
      bg = AppTheme.primaryColor;
      fg = Colors.white;
    } else if (isHint) {
      bg = Colors.amber.shade200;
      fg = AppTheme.textPrimary;
    } else {
      bg = AppTheme.surfaceColor;
      fg = AppTheme.textPrimary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          color: isFound || isSelected
              ? Colors.transparent
              : Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: fg,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── Word chips list ───────────────────────────────────────────────────────────

class _WordChips extends StatelessWidget {
  const _WordChips();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WordSearchGameState>();
    final words = state.puzzle.placedWords.map((pw) => pw.word).toList()
      ..sort();

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: words.length,
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final word = words[i];
          final found = state.foundWords.contains(word);
          return _WordChip(word: word, found: found);
        },
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool found;

  const _WordChip({required this.word, required this.found});

  @override
  Widget build(BuildContext context) {
    // Display with first-letter capitalised for readability.
    final display =
        word[0] + word.substring(1).toLowerCase();

    if (found) {
      return Chip(
        label: Text(
          display,
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            decorationColor: Colors.white,
            color: Colors.white,
            fontSize: AppTheme.fontSmall,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      );
    }

    return Chip(
      label: Text(
        display,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: AppTheme.fontSmall,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppTheme.surfaceColor,
      side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
