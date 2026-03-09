import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/game_info.dart';
import '../../../models/point_transaction.dart';
import '../../../services/game_registry.dart';
import '../../../services/points_manager.dart';
import '../../../services/storage_service.dart';
import '../../../themes/app_theme.dart';
import '../memory_game_state.dart';
import '../memory_models.dart';
import 'memory_play_screen.dart';

class MemoryResultScreen extends StatefulWidget {
  final MemoryGameState gameState;

  const MemoryResultScreen({super.key, required this.gameState});

  @override
  State<MemoryResultScreen> createState() => _MemoryResultScreenState();
}

class _MemoryResultScreenState extends State<MemoryResultScreen>
    with TickerProviderStateMixin {
  // ── Computed on init (no async) ──────────────────────────────────────────────

  late final GameResult _gameResult;
  late final bool _completed;
  late final int _stars;
  late final int _phaseNum;
  late final int _pairsBasePoints;
  late final int _comboBonus;
  late final int _completionBonus;
  late final GameInfo _gameInfo;

  // ── Computed after async save/process ────────────────────────────────────────

  bool _ready = false;
  int _totalEarned = 0;
  int _streakBonusAmount = 0;

  // ── Animations ───────────────────────────────────────────────────────────────

  late final AnimationController _entryCtrl;
  late final Animation<double> _starsScale;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();

    final gs = widget.gameState;

    // Cache the result immediately so timePlayed is accurate.
    _gameResult = gs.getGameResult();
    _completed = gs.matchedPairs == gs.totalPairs;
    _stars = gs.calculateStars();
    _phaseNum = gs.phase.phaseNumber;
    _completionBonus = _completed ? 5 : 0;
    _gameInfo = GameRegistry.getById('memory_cards')!;

    // Approximate base + combo split from the final score.
    final basePerPair = (20 * gs.phase.multiplier).round();
    _pairsBasePoints = basePerPair * gs.matchedPairs;
    _comboBonus = (gs.score - _pairsBasePoints).clamp(0, 99999);

    // Animations.
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

    _saveAndProcess();
  }

  Future<void> _saveAndProcess() async {
    final manager = context.read<PointsManager>();
    final storage = context.read<StorageService>();
    final gs = widget.gameState;

    // 1. Award points (with completion bonus baked in).
    final adjustedResult = GameResult(
      gameId: _gameResult.gameId,
      score: gs.score,
      pointsEarned: gs.score + _completionBonus,
      hintsUsed: _gameResult.hintsUsed,
      skipsUsed: _gameResult.skipsUsed,
      timePlayed: _gameResult.timePlayed,
      status: _gameResult.status,
    );
    _totalEarned = await manager.processGameResult(adjustedResult, _gameInfo);
    _streakBonusAmount =
        (_totalEarned - (gs.score + _completionBonus)).clamp(0, 99999);

    // 2. Update MemoryGameProgress.
    final current = storage.loadMemoryProgress();
    final newPhaseResult = PhaseResult(
      stars: _stars,
      bestTimeSeconds: _gameResult.timePlayed.inSeconds,
      bestScore: gs.score,
      leastErrors: gs.errors,
      playedAt: DateTime.now(),
    );

    // Only overwrite if the new run is strictly better.
    final existing = current.bestResults[_phaseNum];
    final isBetter = existing == null ||
        _stars > existing.stars ||
        (_stars == existing.stars && gs.errors < existing.leastErrors);

    final updatedBests = Map<int, PhaseResult>.from(current.bestResults);
    if (isBetter) updatedBests[_phaseNum] = newPhaseResult;

    // Unlock next phase if this phase was the frontier and the player won.
    var newCurrentPhase = current.currentPhase;
    if (_completed &&
        _phaseNum == current.currentPhase &&
        _phaseNum < MemoryPhase.all.length) {
      newCurrentPhase = _phaseNum + 1;
    }

    await storage.saveMemoryProgress(
      current.copyWith(
        currentPhase: newCurrentPhase,
        bestResults: updatedBests,
      ),
    );

    if (!mounted) return;
    setState(() => _ready = true);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _replayPhase() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MemoryPlayScreen(phaseNumber: _phaseNum),
      ),
    );
  }

  void _nextPhase() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MemoryPlayScreen(phaseNumber: _phaseNum + 1),
      ),
    );
  }

  void _returnHome() {
    // Pop back through result → phase-selection → home.
    Navigator.popUntil(context, ModalRoute.withName('/home'));
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final gs = widget.gameState;
    final hasNext = _completed && _phaseNum < MemoryPhase.all.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────────
              _Header(
                completed: _completed,
                stars: _stars,
                starsScale: _starsScale,
              ),
              const SizedBox(height: 24),

              // ── Stats card ──────────────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: _StatsCard(
                  matchedPairs: gs.matchedPairs,
                  totalPairs: gs.totalPairs,
                  errors: gs.errors,
                  timePlayed: _gameResult.timePlayed,
                  maxCombo: gs.maxCombo,
                  fmtTime: _fmt,
                ),
              ),
              const SizedBox(height: 12),

              // ── Points card ─────────────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: _PointsCard(
                  pairsBasePoints: _pairsBasePoints,
                  comboBonus: _comboBonus,
                  completionBonus: _completionBonus,
                  streakBonus: _streakBonusAmount,
                  total: _totalEarned,
                ),
              ),
              const SizedBox(height: 32),

              // ── Buttons ─────────────────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: _Buttons(
                  hasNext: hasNext,
                  completed: _completed,
                  onNext: _nextPhase,
                  onReplay: _replayPhase,
                  onHome: _returnHome,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool completed;
  final int stars;
  final Animation<double> starsScale;

  const _Header({
    required this.completed,
    required this.stars,
    required this.starsScale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Confetti decoration — only on success.
        if (completed)
          SizedBox(
            width: double.infinity,
            height: 80,
            child: CustomPaint(painter: _ConfettiPainter()),
          ),

        // Title
        Text(
          completed ? 'Parabéns! 🎉' : 'Tempo Esgotado!',
          style: const TextStyle(
            fontSize: AppTheme.fontHero,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),

        if (!completed)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Tente novamente!',
              style: TextStyle(
                fontSize: AppTheme.fontTitle,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 20),

        // Stars — scale-bounce in.
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
                  color: filled ? Colors.amber.shade500 : Colors.grey.shade300,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Confetti painter ──────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  static const _colors = [
    Color(0xFFE53935), // red
    Color(0xFF1E88E5), // blue
    Color(0xFFFFB300), // amber
    Color(0xFF43A047), // green
    Color(0xFF8E24AA), // purple
    Color(0xFFFF7043), // deep orange
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(7); // fixed seed → stable layout
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      paint.color = _colors[i % _colors.length].withValues(alpha: 0.75);
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final radius = rng.nextDouble() * 5 + 2;

      // Alternate between circles and small rotated rectangles.
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
            width: radius * 2.5,
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
  final int matchedPairs;
  final int totalPairs;
  final int errors;
  final Duration timePlayed;
  final int maxCombo;
  final String Function(Duration) fmtTime;

  const _StatsCard({
    required this.matchedPairs,
    required this.totalPairs,
    required this.errors,
    required this.timePlayed,
    required this.maxCombo,
    required this.fmtTime,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.bar_chart_rounded, label: 'Resultado'),
          const SizedBox(height: 12),
          _StatRow(
            label: 'Pares encontrados',
            value: '$matchedPairs/$totalPairs',
            icon: Icons.grid_view_rounded,
            color: AppTheme.primaryColor,
          ),
          _StatRow(
            label: 'Erros',
            value: '$errors',
            icon: Icons.close_rounded,
            color: errors == 0 ? AppTheme.successColor : AppTheme.errorColor,
          ),
          _StatRow(
            label: 'Tempo',
            value: fmtTime(timePlayed),
            icon: Icons.timer_outlined,
            color: AppTheme.textSecondary,
          ),
          _StatRow(
            label: 'Combo máximo',
            value: 'x$maxCombo',
            icon: Icons.local_fire_department_rounded,
            color: Colors.orange.shade700,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ── Points card ───────────────────────────────────────────────────────────────

class _PointsCard extends StatelessWidget {
  final int pairsBasePoints;
  final int comboBonus;
  final int completionBonus;
  final int streakBonus;
  final int total;

  const _PointsCard({
    required this.pairsBasePoints,
    required this.comboBonus,
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
          _CardTitle(icon: Icons.stars_rounded, label: 'Pontos'),
          const SizedBox(height: 12),
          _PointRow(label: 'Pontos dos pares', value: pairsBasePoints),
          if (comboBonus > 0)
            _PointRow(label: 'Bônus de combo', value: comboBonus),
          if (completionBonus > 0)
            _PointRow(label: 'Bônus de conclusão', value: completionBonus),
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
  final bool hasNext;
  final bool completed;
  final VoidCallback onNext;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const _Buttons({
    required this.hasNext,
    required this.completed,
    required this.onNext,
    required this.onReplay,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasNext)
          ElevatedButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Próxima Fase'),
          ),
        if (hasNext) const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onReplay,
          icon: const Icon(Icons.replay_rounded),
          label: const Text('Jogar de Novo'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onHome,
          icon: const Icon(Icons.home_rounded),
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
