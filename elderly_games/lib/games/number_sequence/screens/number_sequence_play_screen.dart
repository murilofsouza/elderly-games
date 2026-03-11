import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/game_info.dart';
import '../../../services/game_registry.dart';
import '../../../themes/app_theme.dart';
import '../../../widgets/game_action_bar.dart';
import '../../../widgets/game_dialogs.dart';
import '../number_sequence_state.dart';
import 'number_sequence_result_screen.dart';

class NumberSequencePlayScreen extends StatefulWidget {
  const NumberSequencePlayScreen({super.key});

  @override
  State<NumberSequencePlayScreen> createState() =>
      _NumberSequencePlayScreenState();
}

class _NumberSequencePlayScreenState extends State<NumberSequencePlayScreen> {
  late final NumberSequenceState _gameState;
  late final GameInfo _gameInfo;
  bool _gameOverHandled = false;

  @override
  void initState() {
    super.initState();
    _gameState = NumberSequenceState();
    _gameInfo  = GameRegistry.getById('number_sequence')!;
    _gameState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (_gameState.isGameOver && !_gameOverHandled) {
      _gameOverHandled = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _handleGameOver());
    }
    if (mounted) setState(() {});
  }

  void _handleGameOver() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NumberSequenceResultScreen(gameState: _gameState),
      ),
    );
  }

  void _onHintUsed() => _gameState.useHint();
  void _onSkipUsed() => _gameState.useSkip();

  Future<bool> _confirmExit() async {
    if (_gameState.isGameOver) return true;
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
    return ChangeNotifierProvider<NumberSequenceState>.value(
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
          appBar: _NumberSequenceAppBar(
            onBack: () async {
              final exit = await _confirmExit();
              if (exit && context.mounted) Navigator.pop(context);
            },
          ),
          body: Column(
            children: [
              // ── Progress bar (fixed) ───────────────────────────────────────
              const _ProgressBar(),

              // ── Sequence / feedback area (flexes, scrolls if needed) ───────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      _SequenceDisplay(),
                      _HintBanner(),
                      _InputDisplay(),
                    ],
                  ),
                ),
              ),

              // ── Numpad (fixed height, never scrolls) ───────────────────────
              const SizedBox(
                height: 280,
                child: _NumPad(),
              ),

              // ── Action bar (fixed) ─────────────────────────────────────────
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

class _NumberSequenceAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onBack;

  const _NumberSequenceAppBar({required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(AppTheme.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NumberSequenceState>();

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Voltar',
        onPressed: onBack,
      ),
      title: const Text('Sequência Numérica'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Center(
            child: Text(
              '${state.challengeNumber}/${state.totalChallenges}',
              style: const TextStyle(
                fontSize: AppTheme.fontTitle,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NumberSequenceState>();
    final progress = state.challengeNumber / state.totalChallenges;

    return Container(
      color: AppTheme.primaryColor.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${state.correctAnswers} ✓',
            style: const TextStyle(
              fontSize: AppTheme.fontSmall,
              fontWeight: FontWeight.w700,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sequence display ──────────────────────────────────────────────────────────

class _SequenceDisplay extends StatelessWidget {
  const _SequenceDisplay();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NumberSequenceState>();
    final challenge = state.currentChallenge;
    final status = state.status;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(challenge.numbers.length, (i) {
          final isSlot = i == challenge.missingIndex;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: isSlot
                  ? _SlotBox(
                      status: status,
                      userInput: state.userInput,
                      answer: challenge.answer,
                    )
                  : _NumberBox(value: challenge.numbers[i]!),
            ),
          );
        }),
      ),
    );
  }
}

/// A normal number box.
class _NumberBox extends StatelessWidget {
  final int value;

  const _NumberBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$value',
          style: const TextStyle(
            fontSize: AppTheme.fontTitle,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// The highlighted slot showing '?', the user's input, and feedback.
class _SlotBox extends StatelessWidget {
  final AnswerStatus status;
  final String userInput;
  final int answer;

  const _SlotBox({
    required this.status,
    required this.userInput,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case AnswerStatus.none:
        bg    = AppTheme.primaryColor;
        fg    = Colors.white;
        label = userInput.isEmpty ? '?' : userInput;

      case AnswerStatus.correct:
        bg    = AppTheme.successColor;
        fg    = Colors.white;
        label = '$answer';

      case AnswerStatus.wrong:
        bg    = AppTheme.errorColor;
        fg    = Colors.white;
        label = '$answer';

      case AnswerStatus.skipped:
        bg    = Colors.amber.shade600;
        fg    = Colors.white;
        label = '$answer';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 64,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.40),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTheme.fontTitle,
            fontWeight: FontWeight.w900,
            color: fg,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── Hint banner ───────────────────────────────────────────────────────────────

class _HintBanner extends StatelessWidget {
  const _HintBanner();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NumberSequenceState>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: state.showHint
          ? Container(
              key: const ValueKey('hint'),
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_rounded,
                      size: 22, color: Colors.amber.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Regra: ${state.currentChallenge.rule}',
                      style: TextStyle(
                        fontSize: AppTheme.fontBody,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(key: ValueKey('no-hint'), height: 0),
    );
  }
}

// ── Input display ─────────────────────────────────────────────────────────────

class _InputDisplay extends StatelessWidget {
  const _InputDisplay();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NumberSequenceState>();
    final input = state.userInput;
    final hasInput = input.isNotEmpty;

    // Show wrong answer below the input when status is wrong.
    final showWrongFeedback = state.status == AnswerStatus.wrong;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: state.isAnswered
                    ? (state.isCorrect
                        ? AppTheme.successColor
                        : state.status == AnswerStatus.skipped
                            ? Colors.amber.shade400
                            : AppTheme.errorColor)
                    : AppTheme.primaryColor,
                width: 2.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                hasInput ? input : '—',
                style: TextStyle(
                  fontSize: AppTheme.fontHeading,
                  fontWeight: FontWeight.w900,
                  color: hasInput ? AppTheme.textPrimary : Colors.grey.shade400,
                  height: 1,
                ),
              ),
            ),
          ),

          // Wrong-answer feedback row.
          if (showWrongFeedback)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Resposta correta: ${state.currentChallenge.answer}',
                style: const TextStyle(
                  fontSize: AppTheme.fontSmall,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.errorColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── NumPad ────────────────────────────────────────────────────────────────────

class _NumPad extends StatelessWidget {
  const _NumPad();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NumberSequenceState>();
    final locked = state.isAnswered;
    final hasInput = state.userInput.isNotEmpty;

    // LayoutBuilder lets us derive childAspectRatio from the actual fixed height
    // (SizedBox(280)) rather than hard-coding a value that breaks on small screens.
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 4 rows with 3 gaps of 8 dp each.
          const rows = 4;
          const gaps = rows - 1;
          final cellH = (constraints.maxHeight - gaps * 8) / rows;
          // 3 columns with 2 gaps.
          const cols = 3;
          final cellW = (constraints.maxWidth - (cols - 1) * 8) / cols;
          final ratio = cellW / cellH;

          return GridView.count(
            crossAxisCount: cols,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: ratio,
            children: [
              // Row 1: 1 2 3
              _NumKey(label: '1', onTap: locked ? null : () => state.appendDigit('1')),
              _NumKey(label: '2', onTap: locked ? null : () => state.appendDigit('2')),
              _NumKey(label: '3', onTap: locked ? null : () => state.appendDigit('3')),

              // Row 2: 4 5 6
              _NumKey(label: '4', onTap: locked ? null : () => state.appendDigit('4')),
              _NumKey(label: '5', onTap: locked ? null : () => state.appendDigit('5')),
              _NumKey(label: '6', onTap: locked ? null : () => state.appendDigit('6')),

              // Row 3: 7 8 9
              _NumKey(label: '7', onTap: locked ? null : () => state.appendDigit('7')),
              _NumKey(label: '8', onTap: locked ? null : () => state.appendDigit('8')),
              _NumKey(label: '9', onTap: locked ? null : () => state.appendDigit('9')),

              // Row 4: ⌫ 0 ✓
              _NumKey(
                icon: Icons.backspace_outlined,
                onTap: (locked || !hasInput) ? null : state.deleteLast,
                color: AppTheme.textSecondary,
              ),
              _NumKey(label: '0', onTap: locked ? null : () => state.appendDigit('0')),
              _NumKey(
                icon: Icons.check_rounded,
                onTap: (locked || !hasInput) ? null : state.submitAnswer,
                color: AppTheme.primaryColor,
                isPrimary: true,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color color;
  final bool isPrimary;

  const _NumKey({
    this.label,
    this.icon,
    required this.onTap,
    this.color = AppTheme.textPrimary,
    this.isPrimary = false,
  }) : assert(label != null || icon != null,
            'Either label or icon must be provided');

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    final Color bgColor = isPrimary
        ? (enabled ? AppTheme.primaryColor : Colors.grey.shade200)
        : (enabled ? AppTheme.surfaceColor : Colors.grey.shade100);

    final Color fgColor = isPrimary
        ? (enabled ? Colors.white : Colors.grey.shade400)
        : (enabled ? color : Colors.grey.shade400);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      elevation: enabled ? 2 : 0,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          child: Center(
            child: label != null
                ? Text(
                    label!,
                    style: TextStyle(
                      fontSize: AppTheme.fontHeading,
                      fontWeight: FontWeight.w800,
                      color: fgColor,
                      height: 1,
                    ),
                  )
                : Icon(icon, size: 30, color: fgColor),
          ),
        ),
      ),
    );
  }
}
