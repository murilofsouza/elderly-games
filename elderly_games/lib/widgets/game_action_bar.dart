import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_info.dart';
import '../services/points_manager.dart';
import '../themes/app_theme.dart';

class GameActionBar extends StatelessWidget {
  final GameInfo game;
  final VoidCallback? onHintUsed;
  final VoidCallback? onSkipUsed;

  const GameActionBar({
    super.key,
    required this.game,
    this.onHintUsed,
    this.onSkipUsed,
  });

  void _showInsufficientPoints(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Pontos insuficientes',
          style: TextStyle(
            fontSize: AppTheme.fontBody,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<PointsManager>();
    final canAffordHint = manager.canAfford(game.hintCost);
    final canAffordSkip = manager.canAfford(game.skipCost);

    return Container(
      height: AppTheme.buttonHeight + 24,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Current points display ──────────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: AppTheme.secondaryColor,
                  size: 26,
                ),
                const SizedBox(width: 6),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${manager.currentPoints}',
                      style: const TextStyle(
                        fontSize: AppTheme.fontTitle,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1,
                      ),
                    ),
                    const Text(
                      'pontos',
                      style: TextStyle(
                        fontSize: AppTheme.fontSmall,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Hint button ─────────────────────────────────────────────────────
          _ActionButton(
            label: 'Dica',
            cost: game.hintCost,
            icon: Icons.lightbulb_rounded,
            color: AppTheme.secondaryColor,
            enabled: canAffordHint,
            onPressed: () async {
              final success = await manager.useHint(game);
              if (!context.mounted) return;
              if (success) {
                onHintUsed?.call();
              } else {
                _showInsufficientPoints(context);
              }
            },
          ),
          const SizedBox(width: 10),

          // ── Skip button ─────────────────────────────────────────────────────
          _ActionButton(
            label: 'Pular',
            cost: game.skipCost,
            icon: Icons.skip_next_rounded,
            color: AppTheme.primaryColor,
            enabled: canAffordSkip,
            onPressed: () async {
              final success = await manager.useSkip(game);
              if (!context.mounted) return;
              if (success) {
                onSkipUsed?.call();
              } else {
                _showInsufficientPoints(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final int cost;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.cost,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : Colors.grey.shade400;

    return SizedBox(
      height: AppTheme.buttonHeight,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? color.withValues(alpha: 0.12)
              : Colors.grey.shade100,
          foregroundColor: effectiveColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
            side: BorderSide(
              color: enabled
                  ? color.withValues(alpha: 0.40)
                  : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          minimumSize: const Size(AppTheme.minTouchTarget, AppTheme.buttonHeight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: effectiveColor),
            const SizedBox(width: 6),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppTheme.fontSmall,
                    fontWeight: FontWeight.w700,
                    color: effectiveColor,
                    height: 1.1,
                  ),
                ),
                Text(
                  '-$cost pts',
                  style: TextStyle(
                    fontSize: AppTheme.fontSmall,
                    fontWeight: FontWeight.w600,
                    color: effectiveColor.withValues(alpha: 0.80),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
