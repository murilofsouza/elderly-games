import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

/// Shows a confirmation dialog before leaving a game.
/// Returns `true` if the user chooses to exit, `false` to keep playing.
Future<bool> showExitGameDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
      ),
      title: const Text(
        'Sair do jogo?',
        style: TextStyle(
          fontSize: AppTheme.fontTitle,
          fontWeight: FontWeight.w800,
          color: AppTheme.textPrimary,
        ),
      ),
      content: const Text(
        'Quer sair? O progresso desta partida será perdido.',
        style: TextStyle(
          fontSize: AppTheme.fontBody,
          color: AppTheme.textSecondary,
          height: 1.5,
        ),
      ),
      actionsPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        // Primary action: keep playing
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(140, AppTheme.buttonHeight),
          ),
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Continuar Jogando'),
        ),
        // Secondary action: exit
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(100, AppTheme.buttonHeight),
            foregroundColor: AppTheme.errorColor,
            side: const BorderSide(color: AppTheme.errorColor, width: 2),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(
            'Sair',
            style: TextStyle(color: AppTheme.errorColor),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Shows a floating SnackBar indicating the user cannot afford the action.
void showInsufficientPointsSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text(
        'Pontos insuficientes! Continue jogando para ganhar mais.',
        style: TextStyle(
          fontSize: AppTheme.fontBody,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: AppTheme.errorColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () =>
            ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    ),
  );
}
