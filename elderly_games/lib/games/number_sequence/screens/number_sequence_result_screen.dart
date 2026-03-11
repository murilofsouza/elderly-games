import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/game_info.dart';
import '../../../models/point_transaction.dart';
import '../../../services/game_registry.dart';
import '../../../services/points_manager.dart';
import '../../../themes/app_theme.dart';
import '../number_sequence_state.dart';
import 'number_sequence_play_screen.dart';

class NumberSequenceResultScreen extends StatefulWidget {
  final NumberSequenceState gameState;

  const NumberSequenceResultScreen({super.key, required this.gameState});

  @override
  State<NumberSequenceResultScreen> createState() =>
      _NumberSequenceResultScreenState();
}

class _NumberSequenceResultScreenState
    extends State<NumberSequenceResultScreen>
    with TickerProviderStateMixin {
  // ── Computed on init ─────────────────────────────────────────────────────────

  late final int _stars;
  late final int _completionBonus;
  late final GameInfo _gameInfo;
  late final Duration _timePlayed;

  // ── Computed after async process ──────────────────────────────────────────────

  bool _ready = false;
  int _totalEarned = 0;
  int _streakBonusAmount = 0;

  // ── Animations ────────────────────────────────────────────────────────────────

  late final AnimationController _entryCtrl;
  late final Animation<double> _starsScale;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    final gs = widget.gameState;

    _gameInfo    = GameRegistry.getById('number_sequence')!;
    _timePlayed  = gs.getGameResult().timePlayed;

    // Completion bonus: +10 if perfect round (all correct, no skips).
    final perfect = gs.correctAnswers == gs.totalChallenges && gs.skipsUsed == 0;
    _completionBonus = perfect ? 10 : 0;

    // Star rating:
    //   3 → ≥9 correct, no skip used
    //   2 → ≥6 correct, or 9+ with skip
    //   1 → ≥1 correct
    //   0 → nothing correct
    if (gs.correctAnswers == 0) {
      _stars = 0;
    } else if (gs.correctAnswers >= 9 && gs.skipsUsed == 0) {
      _stars = 3;
    } else if (gs.correctAnswers >= 6) {
      _stars = 2;
    } else {
      _stars = 1;
    }

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _starsScale = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );
    _contentFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );

    _processPoints();
  }

  Future<void> _processPoints() async {
    final gs      = widget.gameState;
    final manager = context.read<PointsManager>();

    final result = GameResult(
      gameId:       _gameInfo.id,
      score:        gs.score,
      pointsEarned: gs.score + _completionBonus,
      hintsUsed:    gs.hintsUsed,
      skipsUsed:    gs.skipsUsed,
      timePlayed:   _timePlayed,
      status:       GameStatus.completed,
    );

    _totalEarned       = await manager.processGameResult(result, _gameInfo);
    _streakBonusAmount =
        (_totalEarned - (gs.score + _completionBonus)).clamp(0, 99999);

    if (!mounted) return;
    setState(() => _ready = true);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String _fmtTime(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _encouragement(int correct, int total) {
    final ratio = correct / total;
    if (ratio == 1.0) return 'Perfeito! Você acertou tudo!';
    if (ratio >= 0.9) return 'Excelente! Quase perfeito!';
    if (ratio >= 0.7) return 'Muito bem! Continue praticando!';
    if (ratio >= 0.5) return 'Bom começo! Você vai melhorar!';
    return 'Continue tentando! A prática leva à perfeição!';
  }

  void _playAgain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NumberSequencePlayScreen()),
    );
  }

  void _returnHome() {
    Navigator.popUntil(context, ModalRoute.withName('/home'));
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final gs = widget.gameState;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────────
              _Header(
                stars:          _stars,
                starsScale:     _starsScale,
                encouragement:  _encouragement(
                    gs.correctAnswers, gs.totalChallenges),
              ),
              const SizedBox(height: 24),

              // ── Stats card ────────────────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: _StatsCard(
                  correctAnswers: gs.correctAnswers,
                  totalChallenges: gs.totalChallenges,
                  timePlayed:  _timePlayed,
                  hintsUsed:   gs.hintsUsed,
                  skipsUsed:   gs.skipsUsed,
                  fmtTime:     _fmtTime,
                ),
              ),
              const SizedBox(height: 12),

              // ── Points card ───────────────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: _PointsCard(
                  baseScore:        gs.score,
                  completionBonus:  _completionBonus,
                  streakBonus:      _streakBonusAmount,
                  total:            _totalEarned,
                ),
              ),
              const SizedBox(height: 32),

              // ── Buttons ───────────────────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: _Buttons(
                  onPlayAgain: _playAgain,
                  onHome:      _returnHome,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int stars;
  final Animation<double> starsScale;
  final String encouragement;

  const _Header({
    required this.stars,
    required this.starsScale,
    required this.encouragement,
  });

  @override
  Widget build(BuildContext context) {
    final allCorrect = stars == 3;

    return Column(
      children: [
        // Confetti decoration on a perfect / near-perfect round.
        if (allCorrect)
          SizedBox(
            width: double.infinity,
            height: 80,
            child: CustomPaint(painter: _ConfettiPainter()),
          ),

        const Text(
          'Parabéns!',
          style: TextStyle(
            fontSize: AppTheme.fontHero,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),

        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            encouragement,
            style: const TextStyle(
              fontSize: AppTheme.fontTitle,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 20),

        ScaleTransition(
          scale: starsScale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final filled = i < stars;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 56,
                  color: filled
                      ? Colors.amber.shade500
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Confetti painter ───────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  static const _colors = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFFFFB300),
    Color(0xFF43A047),
    Color(0xFF8E24AA),
    Color(0xFFFF7043),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng   = Random(42); // fixed seed → stable layout
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      paint.color = _colors[i % _colors.length].withValues(alpha: 0.75);
      final x      = rng.nextDouble() * size.width;
      final y      = rng.nextDouble() * size.height;
      final radius = rng.nextDouble() * 5 + 2;

      if (i.isEven) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      } else {
        final angle = rng.nextDouble() * pi;
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width:  radius * 2.5,
            height: radius,
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter _) => false;
}

// ── Stats card ────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final int correctAnswers;
  final int totalChallenges;
  final Duration timePlayed;
  final int hintsUsed;
  final int skipsUsed;
  final String Function(Duration) fmtTime;

  const _StatsCard({
    required this.correctAnswers,
    required this.totalChallenges,
    required this.timePlayed,
    required this.hintsUsed,
    required this.skipsUsed,
    required this.fmtTime,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
              icon: Icons.bar_chart_rounded, label: 'Resultado'),
          const SizedBox(height: 12),
          _StatRow(
            label: 'Respostas corretas',
            value: '$correctAnswers/$totalChallenges',
            icon:  Icons.check_circle_rounded,
            color: correctAnswers == totalChallenges
                ? AppTheme.successColor
                : AppTheme.primaryColor,
          ),
          _StatRow(
            label: 'Tempo',
            value: fmtTime(timePlayed),
            icon:  Icons.timer_outlined,
            color: AppTheme.textSecondary,
          ),
          _StatRow(
            label: 'Dicas usadas',
            value: '$hintsUsed',
            icon:  Icons.lightbulb_outline_rounded,
            color: hintsUsed == 0
                ? AppTheme.successColor
                : Colors.amber.shade700,
          ),
          _StatRow(
            label: 'Pulos usados',
            value: '$skipsUsed',
            icon:  Icons.skip_next_rounded,
            color: skipsUsed == 0
                ? AppTheme.successColor
                : AppTheme.errorColor,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ── Points card ───────────────────────────────────────────────────────────────

class _PointsCard extends StatelessWidget {
  final int baseScore;
  final int completionBonus;
  final int streakBonus;
  final int total;

  const _PointsCard({
    required this.baseScore,
    required this.completionBonus,
    required this.streakBonus,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.stars_rounded, label: 'Pontos'),
          const SizedBox(height: 12),
          _PointRow(label: 'Respostas corretas', value: baseScore),
          if (completionBonus > 0)
            _PointRow(label: 'Bônus de perfeição', value: completionBonus),
          if (streakBonus > 0)
            _PointRow(label: 'Bônus de sequência', value: streakBonus),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: AppTheme.fontTitle,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '+$total pts',
                style: const TextStyle(
                  fontSize: AppTheme.fontHeading,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.pointsColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────────

class _Buttons extends StatelessWidget {
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const _Buttons({required this.onPlayAgain, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: onPlayAgain,
          icon:  const Icon(Icons.replay_rounded),
          label: const Text('Jogar de Novo'),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onHome,
          icon:  const Icon(Icons.home_rounded),
          label: const Text('Voltar aos Jogos'),
        ),
      ],
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CardTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontTitle,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLast;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontBody,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTheme.fontBody,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointRow extends StatelessWidget {
  final String label;
  final int value;

  const _PointRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.fontBody,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            '+$value',
            style: const TextStyle(
              fontSize: AppTheme.fontBody,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
