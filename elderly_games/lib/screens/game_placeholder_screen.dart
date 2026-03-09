import 'package:flutter/material.dart';

import '../models/game_info.dart';
import '../themes/app_theme.dart';
import '../widgets/game_action_bar.dart';
import '../widgets/game_dialogs.dart';

class GamePlaceholderScreen extends StatelessWidget {
  final GameInfo game;

  const GamePlaceholderScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final exit = await showExitGameDialog(context);
        if (exit && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(game.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Voltar',
            onPressed: () async {
              final exit = await showExitGameDialog(context);
              if (exit && context.mounted) Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Construction icon ─────────────────────────────────
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.construction_rounded,
                          size: 80,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Title ─────────────────────────────────────────────
                      Text(
                        game.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: AppTheme.fontHeading,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Message ───────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius:
                              BorderRadius.circular(AppTheme.cardBorderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Este jogo está sendo desenvolvido.\nEm breve disponível!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppTheme.fontBody,
                            color: AppTheme.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Info chips ────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _InfoChip(
                            icon: Icons.category_rounded,
                            label: GameInfo.categoryLabel(game.category),
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          _InfoChip(
                            icon: Icons.stars_rounded,
                            label: '${game.basePoints} pts base',
                            color: AppTheme.pointsColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // ── Back button ───────────────────────────────────────
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, size: 24),
                        label: const Text('Voltar aos Jogos'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Action bar ────────────────────────────────────────────────
              GameActionBar(
                game: game,
                onHintUsed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Dica usada! (demo)',
                        style: TextStyle(
                          fontSize: AppTheme.fontBody,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      backgroundColor: AppTheme.secondaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onSkipUsed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Pular usado! (demo)',
                        style: TextStyle(
                          fontSize: AppTheme.fontBody,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: AppTheme.fontSmall,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
