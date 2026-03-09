import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/game_info.dart';
import '../../../services/game_registry.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/game_action_bar.dart';
import '../../../widgets/game_dialogs.dart';
import '../memory_game_state.dart';
import '../memory_models.dart';
import 'memory_result_screen.dart';

class MemoryPlayScreen extends StatefulWidget {
  final int phaseNumber;

  const MemoryPlayScreen({super.key, required this.phaseNumber});

  @override
  State<MemoryPlayScreen> createState() => _MemoryPlayScreenState();
}

class _MemoryPlayScreenState extends State<MemoryPlayScreen> {
  late final MemoryGameState _gameState;
  late final GameInfo _gameInfo;

  // Indices of cards currently lit up by a hint (golden border for 1.5s).
  Set<int> _highlightedIndices = const {};

  // Local countdown shown in the preview overlay (3 → 1).
  int _previewCountdown = 3;
  Timer? _previewTimer;

  bool _gameOverHandled = false;

  @override
  void initState() {
    super.initState();
    _gameState = MemoryGameState(phaseNumber: widget.phaseNumber);
    _gameInfo = GameRegistry.getById('memory_cards')!;
    _gameState.addListener(_onStateChanged);

    if (_gameState.isPreviewMode) {
      _startPreviewCountdown();
    }
  }

  void _startPreviewCountdown() {
    _previewCountdown = 3;
    _previewTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_previewCountdown <= 1) {
        t.cancel();
        return;
      }
      setState(() => _previewCountdown--);
    });
  }

  void _onStateChanged() {
    if (_gameState.isGameOver && !_gameOverHandled) {
      _gameOverHandled = true;
      // Post-frame so we don't navigate during a build.
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleGameOver());
    }
    if (mounted) setState(() {});
  }

  void _handleGameOver() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MemoryResultScreen(gameState: _gameState),
      ),
    );
  }

  // Called after GameActionBar deducts the hint cost from PointsManager.
  void _onHintUsed() {
    final pair = _gameState.useHint();
    if (pair == null) return; // limit already reached (edge case)
    _animateHint(pair);
  }

  void _animateHint(List<int> indices) {
    setState(() => _highlightedIndices = indices.toSet());
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _highlightedIndices = const {});
    });
  }

  // Called after GameActionBar deducts the skip cost from PointsManager.
  void _onSkipUsed() {
    _gameState.useSkip();
  }

  Future<bool> _confirmExit() async {
    if (_gameState.isGameOver) return true;
    return showExitGameDialog(context);
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _gameState.removeListener(_onStateChanged);
    _gameState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MemoryGameState>.value(
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
          appBar: _MemoryAppBar(
            phaseNumber: widget.phaseNumber,
            onBack: () async {
              final exit = await _confirmExit();
              if (exit && context.mounted) Navigator.pop(context);
            },
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // ── Status row ─────────────────────────────────────────────
                  const _StatusBar(),

                  // ── Card grid ──────────────────────────────────────────────
                  Expanded(
                    child: _CardGrid(
                      phase: _gameState.phase,
                      highlightedIndices: _highlightedIndices,
                    ),
                  ),

                  // ── Action bar (hint / skip) ────────────────────────────────
                  GameActionBar(
                    game: _gameInfo,
                    onHintUsed: _onHintUsed,
                    onSkipUsed: _onSkipUsed,
                  ),
                ],
              ),

              // ── Preview overlay ─────────────────────────────────────────────
              if (_gameState.isPreviewMode)
                _PreviewOverlay(countdown: _previewCountdown),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────

class _MemoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int phaseNumber;
  final VoidCallback onBack;

  const _MemoryAppBar({required this.phaseNumber, required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(AppTheme.appBarHeight);

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final secs = context.watch<MemoryGameState>().timeRemainingSeconds;
    final urgent = secs != null && secs < 30;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Voltar',
        onPressed: onBack,
      ),
      title: Text('Fase $phaseNumber'),
      actions: [
        if (secs != null)
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 20,
                  color: urgent ? Colors.red.shade200 : Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  _fmt(secs),
                  style: TextStyle(
                    fontSize: AppTheme.fontTitle,
                    fontWeight: FontWeight.w800,
                    color: urgent ? Colors.red.shade200 : Colors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Status bar ────────────────────────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<MemoryGameState>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: pairs
          _StatusChip(
            icon: Icons.grid_view_rounded,
            label: 'Pares: ${s.matchedPairs}/${s.totalPairs}',
            color: AppTheme.primaryColor,
          ),

          // Centre: combo (only when > 1)
          if (s.currentCombo > 1)
            _StatusChip(
              icon: Icons.local_fire_department_rounded,
              label: 'Combo x${s.currentCombo}',
              color: Colors.amber.shade700,
              bold: true,
            )
          else
            const SizedBox.shrink(),

          // Right: errors
          _StatusChip(
            icon: Icons.close_rounded,
            label: 'Erros: ${s.errors}',
            color:
                s.errors > 0 ? AppTheme.errorColor : AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool bold;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTheme.fontSmall,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Card grid ─────────────────────────────────────────────────────────────────

class _CardGrid extends StatelessWidget {
  final MemoryPhase phase;
  final Set<int> highlightedIndices;

  const _CardGrid({required this.phase, required this.highlightedIndices});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MemoryGameState>();
    const padding = 12.0;
    const spacing = 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the cell aspect ratio so every card fills the screen
        // exactly, regardless of the grid dimensions (rows x columns).
        final cellW =
            (constraints.maxWidth - padding * 2 - spacing * (phase.columns - 1)) /
                phase.columns;
        final cellH =
            (constraints.maxHeight - padding * 2 - spacing * (phase.rows - 1)) /
                phase.rows;

        // Never go below 70 dp — let the grid scroll for very large phases.
        final effectiveCellH = cellH.clamp(70.0, double.infinity);
        final aspectRatio = cellW / effectiveCellH;

        return GridView.builder(
          padding: const EdgeInsets.all(padding),
          physics: effectiveCellH > cellH
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: phase.columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: state.cards.length,
          itemBuilder: (context, i) => _CardTile(
            card: state.cards[i],
            isHighlighted: highlightedIndices.contains(i),
            onTap: () => state.flipCard(i),
          ),
        );
      },
    );
  }
}

// ── Individual card tile ──────────────────────────────────────────────────────

class _CardTile extends StatelessWidget {
  final MemoryCard card;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _CardTile({
    required this.card,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final faceUp = card.isFlipped || card.isMatched;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isHighlighted
              ? Border.all(color: Colors.amber.shade500, width: 3.5)
              : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            // Sprint 4: replace with 3D Matrix4.rotateY flip.
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: child,
            ),
            child: faceUp
                ? _CardFace(key: const ValueKey('face'), card: card)
                : const _CardBack(key: ValueKey('back')),
          ),
        ),
      ),
    );
  }
}

// ── Card face (emoji + label) ─────────────────────────────────────────────────

class _CardFace extends StatelessWidget {
  final MemoryCard card;

  const _CardFace({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: card.isMatched
          ? AppTheme.successColor.withValues(alpha: 0.10)
          : AppTheme.surfaceColor,
      child: Stack(
        children: [
          // Content
          Center(
            child: Opacity(
              opacity: card.isMatched ? 0.70 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    card.imageAsset,
                    style: const TextStyle(fontSize: 40),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: card.isMatched
                          ? AppTheme.successColor
                          : AppTheme.textPrimary,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),

          // Matched check badge
          if (card.isMatched)
            const Positioned(
              top: 5,
              right: 5,
              child: Icon(
                Icons.check_circle_rounded,
                color: AppTheme.successColor,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Card back (dark green pattern) ───────────────────────────────────────────

class _CardBack extends StatelessWidget {
  const _CardBack({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.25,
          child: Icon(
            Icons.grid_3x3_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Preview overlay ───────────────────────────────────────────────────────────

class _PreviewOverlay extends StatelessWidget {
  final int countdown;

  const _PreviewOverlay({required this.countdown});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.08),
          ),
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Memorize!',
                    style: TextStyle(
                      fontSize: AppTheme.fontHeading,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Text(
                      '$countdown',
                      key: ValueKey(countdown),
                      style: const TextStyle(
                        fontSize: AppTheme.fontHero,
                        fontWeight: FontWeight.w900,
                        color: Colors.amber,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
