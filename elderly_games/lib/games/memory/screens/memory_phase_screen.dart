import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/points_manager.dart';
import '../../../services/storage_service.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/points_display.dart';
import '../memory_models.dart';

class MemoryPhaseScreen extends StatefulWidget {
  const MemoryPhaseScreen({super.key});

  @override
  State<MemoryPhaseScreen> createState() => _MemoryPhaseScreenState();
}

class _MemoryPhaseScreenState extends State<MemoryPhaseScreen> {
  MemoryGameProgress? _progress;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    final progress = context.read<StorageService>().loadMemoryProgress();
    setState(() => _progress = progress);
  }

  Future<void> _onPhaseTap(int phaseNumber) async {
    await Navigator.pushNamed(
      context,
      '/memory/game',
      arguments: phaseNumber,
    );
    // Refresh stars/progress when returning from the game.
    if (mounted) _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<PointsManager>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Jogo da Memória'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PointsDisplay(
              totalPoints: manager.totalPoints,
              currentPoints: manager.currentPoints,
              dailyStreak: manager.dailyStreak,
            ),
          ),
        ],
      ),
      body: _progress == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                // ~0.75 leaves enough height for all card content (phase label,
                // emoji, pairs, timer, stars) at 120dp+ per card.
                childAspectRatio: 0.72,
                children: MemoryPhase.all.map((phase) {
                  final isUnlocked =
                      phase.phaseNumber <= _progress!.currentPhase;
                  final best = _progress!.bestResults[phase.phaseNumber];
                  return _PhaseCard(
                    phase: phase,
                    isUnlocked: isUnlocked,
                    best: best,
                    onTap: isUnlocked
                        ? () => _onPhaseTap(phase.phaseNumber)
                        : null,
                  );
                }).toList(),
              ),
            ),
    );
  }
}

// ── Phase card ────────────────────────────────────────────────────────────────

class _PhaseCard extends StatelessWidget {
  final MemoryPhase phase;
  final bool isUnlocked;
  final PhaseResult? best;
  final VoidCallback? onTap;

  const _PhaseCard({
    required this.phase,
    required this.isUnlocked,
    this.best,
    this.onTap,
  });

  String get _themeEmoji => switch (phase.theme) {
        MemoryTheme.fruits => '🍎',
        MemoryTheme.animals => '🐱',
        MemoryTheme.mixed => '🎲',
      };

  String get _themeLabel => switch (phase.theme) {
        MemoryTheme.fruits => 'Frutas',
        MemoryTheme.animals => 'Animais',
        MemoryTheme.mixed => 'Misto',
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isUnlocked
          ? 'Fase ${phase.phaseNumber}: $_themeLabel, ${phase.pairs} pares'
          : 'Fase ${phase.phaseNumber} bloqueada',
      button: isUnlocked,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 120),
          decoration: BoxDecoration(
            color: isUnlocked ? AppTheme.surfaceColor : const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
            border: Border.all(
              color: isUnlocked
                  ? AppTheme.primaryColor
                  : Colors.grey.shade300,
              width: isUnlocked ? 2.5 : 1.5,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.14),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // ── Card content ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Phase number
                    Text(
                      'FASE ${phase.phaseNumber}',
                      style: TextStyle(
                        fontSize: AppTheme.fontTitle,
                        fontWeight: FontWeight.w900,
                        color: isUnlocked
                            ? AppTheme.primaryColor
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Theme emoji
                    Text(
                      _themeEmoji,
                      style: TextStyle(fontSize: isUnlocked ? 36 : 28),
                    ),
                    const SizedBox(height: 6),

                    // Theme label
                    Text(
                      _themeLabel,
                      style: TextStyle(
                        fontSize: AppTheme.fontSmall,
                        fontWeight: FontWeight.w700,
                        color: isUnlocked
                            ? AppTheme.textPrimary
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Pairs count
                    Text(
                      '${phase.pairs} pares',
                      style: TextStyle(
                        fontSize: AppTheme.fontSmall,
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? AppTheme.textSecondary
                            : Colors.grey.shade400,
                      ),
                    ),

                    // Time limit (only for timed phases)
                    if (phase.timeLimitSeconds != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: isUnlocked
                                  ? Colors.orange.shade700
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${phase.timeLimitSeconds! ~/ 60} min',
                              style: TextStyle(
                                fontSize: AppTheme.fontSmall,
                                fontWeight: FontWeight.w700,
                                color: isUnlocked
                                    ? Colors.orange.shade700
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),

                    // Stars
                    _StarRow(
                      earned: best?.stars ?? 0,
                      isUnlocked: isUnlocked,
                    ),
                  ],
                ),
              ),

              // ── Locked overlay ────────────────────────────────────────────
              if (!isUnlocked)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300.withValues(alpha: 0.45),
                      borderRadius:
                          BorderRadius.circular(AppTheme.cardBorderRadius),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_rounded,
                        size: 44,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Star row ──────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final int earned; // 0-3
  final bool isUnlocked;

  const _StarRow({required this.earned, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < earned;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          size: 30,
          color: !isUnlocked
              ? Colors.grey.shade300
              : filled
                  ? Colors.amber.shade600
                  : Colors.grey.shade400,
        );
      }),
    );
  }
}
