import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/game_info.dart';
import '../themes/app_theme.dart';

class GameCard extends StatelessWidget {
  final GameInfo game;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.game,
    required this.isUnlocked,
    this.onTap,
  });

  static Color _categoryColor(GameCategory cat) {
    switch (cat) {
      case GameCategory.memory:
        return const Color(0xFF1565C0); // blue
      case GameCategory.words:
        return const Color(0xFF6A1B9A); // purple
      case GameCategory.puzzle:
        return const Color(0xFF00695C); // teal
      case GameCategory.numbers:
        return const Color(0xFF283593); // indigo
      case GameCategory.trivia:
        return const Color(0xFFE65100); // orange
    }
  }

  static IconData _categoryIcon(GameCategory cat) {
    switch (cat) {
      case GameCategory.memory:
        return Icons.grid_view_rounded;
      case GameCategory.words:
        return Icons.abc_rounded;
      case GameCategory.puzzle:
        return Icons.extension_rounded;
      case GameCategory.numbers:
        return Icons.tag_rounded;
      case GameCategory.trivia:
        return Icons.lightbulb_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(game.category);
    final locked = !isUnlocked;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        elevation: 3,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ── Icon container ────────────────────────────────────────────
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: locked
                        ? Colors.grey.shade200
                        : color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    locked ? Icons.lock_rounded : _categoryIcon(game.category),
                    color: locked ? Colors.grey.shade400 : color,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),

                // ── Text content ──────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.title,
                        style: TextStyle(
                          fontSize: AppTheme.fontBody,
                          fontWeight: FontWeight.w800,
                          color: locked
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSmall,
                          color: AppTheme.textSecondary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Chip(
                            label: GameInfo.categoryLabel(game.category),
                            color: locked ? Colors.grey : color,
                          ),
                          const SizedBox(width: 6),
                          _Chip(
                            label: '+${game.basePoints} pts',
                            color: locked
                                ? Colors.grey
                                : AppTheme.pointsColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // ── Right side ────────────────────────────────────────────────
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (locked && !game.isFree)
                      _PriceBadge(price: game.price)
                    else
                      Icon(
                        locked
                            ? Icons.lock_rounded
                            : Icons.chevron_right_rounded,
                        color: locked
                            ? Colors.grey.shade400
                            : AppTheme.primaryColor,
                        size: 32,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTheme.fontSmall,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

class _PriceBadge extends StatelessWidget {
  final double price;

  const _PriceBadge({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'R\$${price.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: AppTheme.fontSmall,
          fontWeight: FontWeight.w800,
          color: AppColors.btnSecondaryText,
        ),
      ),
    );
  }
}
