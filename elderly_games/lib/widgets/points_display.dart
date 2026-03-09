import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class PointsDisplay extends StatelessWidget {
  final int totalPoints;
  final int currentPoints;
  final int dailyStreak;

  const PointsDisplay({
    super.key,
    required this.totalPoints,
    required this.currentPoints,
    required this.dailyStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(
            icon: Icons.stars_rounded,
            iconColor: AppTheme.secondaryColor,
            value: currentPoints,
            label: 'pts',
          ),
          Container(
            width: 1.5,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white.withValues(alpha: 0.40),
          ),
          _Pill(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppTheme.pointsColor,
            value: dailyStreak,
            label: 'dias',
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int value;
  final String label;

  const _Pill({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 5),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppTheme.fontBody,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: AppTheme.fontSmall,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ],
    );
  }
}
