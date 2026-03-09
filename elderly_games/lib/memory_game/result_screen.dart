import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';
import 'storage.dart';
import 'game_screen.dart';
import 'game_data.dart';

class ResultScreen extends StatefulWidget {
  final PhaseConfig config;
  final int pairsFound;
  final int totalPairs;
  final int errors;
  final int elapsedSeconds;
  final int maxCombo;
  final int pairPoints;
  final int completionBonus;
  final int perfectBonus;
  final int totalScore;
  final int stars;
  final bool timedOut;

  const ResultScreen({
    super.key,
    required this.config,
    required this.pairsFound,
    required this.totalPairs,
    required this.errors,
    required this.elapsedSeconds,
    required this.maxCombo,
    required this.pairPoints,
    required this.completionBonus,
    required this.perfectBonus,
    required this.totalScore,
    required this.stars,
    required this.timedOut,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late List<_ConfettiParticle> _particles;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particles = List.generate(30, (_) => _ConfettiParticle());

    if (!widget.timedOut) {
      _confettiController.forward();
    }

    _saveResult();
  }

  Future<void> _saveResult() async {
    if (_saved) return;
    _saved = true;

    final result = PhaseResult(
      stars: widget.stars,
      bestTime: widget.elapsedSeconds,
      bestScore: widget.totalScore,
      errors: widget.errors,
      playedAt: DateTime.now(),
    );

    final progress = await MemoryGameStorage.loadProgress();
    await MemoryGameStorage.updatePhaseResult(
        widget.config.phase, result, progress);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasNextPhase = widget.config.phase < 8 && !widget.timedOut;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    widget.timedOut ? 'Tempo esgotado!' : 'Parabens!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: widget.timedOut
                          ? Colors.orange.shade700
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fase ${widget.config.phase} ${widget.timedOut ? "" : "- Completa!"}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < widget.stars ? Icons.star : Icons.star_border,
                          size: 48,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Stats card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _StatRow(
                          label: 'Pares encontrados',
                          value: '${widget.pairsFound}/${widget.totalPairs}',
                        ),
                        _StatRow(
                          label: 'Erros',
                          value: '${widget.errors}',
                        ),
                        _StatRow(
                          label: 'Tempo',
                          value: _formatTime(widget.elapsedSeconds),
                        ),
                        _StatRow(
                          label: 'Combo maximo',
                          value: 'x${widget.maxCombo}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Points breakdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _ScoreRow(
                          label: 'Pontos dos pares',
                          value: '+${widget.pairPoints}',
                        ),
                        if (widget.completionBonus > 0)
                          _ScoreRow(
                            label: 'Bonus conclusao',
                            value: '+${widget.completionBonus}',
                          ),
                        if (widget.perfectBonus > 0)
                          _ScoreRow(
                            label: 'Memoria Perfeita!',
                            value: '+${widget.perfectBonus}',
                            highlight: true,
                          ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '+${widget.totalScore}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 22),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  if (hasNextPhase)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          final nextPhase = phases[widget.config.phase];
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  GameScreen(config: nextPhase),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Proxima Fase'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    GameScreen(config: widget.config),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Jogar de Novo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Voltar'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Confetti overlay
            if (!widget.timedOut)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _ConfettiPainter(
                          particles: _particles,
                          progress: _confettiController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ScoreRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: highlight ? Colors.amber.shade800 : Colors.grey.shade700,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: highlight ? Colors.amber.shade800 : const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}


class _ConfettiParticle {
  late double x;
  late double y;
  late double speed;
  late double size;
  late Color color;
  late double rotation;

  static final _random = Random();
  static const _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  _ConfettiParticle() {
    x = _random.nextDouble();
    y = -_random.nextDouble() * 0.3;
    speed = 0.3 + _random.nextDouble() * 0.7;
    size = 4 + _random.nextDouble() * 6;
    color = _colors[_random.nextInt(_colors.length)];
    rotation = _random.nextDouble() * pi * 2;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = p.y + progress * p.speed * 1.5;
      if (currentY > 1.2) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: (1 - progress).clamp(0, 1))
        ..style = PaintingStyle.fill;

      final x = p.x * size.width + sin(progress * pi * 4 + p.rotation) * 20;
      final y = currentY * size.height;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * pi * 2 * p.speed + p.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
