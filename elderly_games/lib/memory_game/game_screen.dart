import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'game_data.dart';
import 'widgets/memory_card.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final PhaseConfig config;

  const GameScreen({super.key, required this.config});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late List<GameCard> _cards;
  GameCard? _firstFlipped;
  bool _isChecking = false;
  int _pairsFound = 0;
  int _errors = 0;
  int _comboCount = 0;
  int _maxCombo = 0;
  int _score = 0;
  int _hintsRemaining = 3;
  int _skipsRemaining = 1;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isPreview = false;
  bool _gameStarted = false;
  final Set<String> _hintedCardIds = {};
  final List<_FloatingScore> _floatingScores = [];
  int _floatingScoreId = 0;
  final Set<int> _shakingCards = {};

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    final selectedCards = getCardsForTheme(widget.config.theme, widget.config.pairs);
    _cards = [];
    for (int i = 0; i < selectedCards.length; i++) {
      _cards.add(GameCard(index: _cards.length, card: selectedCards[i]));
      _cards.add(GameCard(index: _cards.length, card: selectedCards[i]));
    }
    _cards.shuffle();
    // Reassign indices after shuffle
    for (int i = 0; i < _cards.length; i++) {
      _cards[i] = GameCard(index: i, card: _cards[i].card);
    }

    if (widget.config.hasPreview) {
      _isPreview = true;
      for (final card in _cards) {
        card.isFlipped = true;
      }
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          _isPreview = false;
          for (final card in _cards) {
            card.isFlipped = false;
          }
          _startGame();
        });
      });
    } else {
      _startGame();
    }
  }

  void _startGame() {
    _gameStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
      });

      // Check time limit
      if (widget.config.timeLimitSeconds != null &&
          _elapsedSeconds >= widget.config.timeLimitSeconds!) {
        _timeUp();
      }
    });
  }

  void _timeUp() {
    _timer?.cancel();
    // Game over - show result with what was achieved
    _showResult(timedOut: true);
  }

  void _onCardTap(int index) {
    if (_isPreview || _isChecking || !_gameStarted) return;

    final card = _cards[index];
    if (card.isMatched) return;

    // Tapping already flipped card = unflip it
    if (card.isFlipped && _firstFlipped == card) {
      HapticFeedback.lightImpact();
      setState(() {
        card.isFlipped = false;
        _firstFlipped = null;
      });
      return;
    }

    if (card.isFlipped) return;

    HapticFeedback.lightImpact();
    setState(() {
      card.isFlipped = true;
    });

    if (_firstFlipped == null) {
      _firstFlipped = card;
    } else {
      _isChecking = true;
      final first = _firstFlipped!;
      _firstFlipped = null;

      if (first.card.id == card.card.id) {
        // Match!
        _comboCount++;
        if (_comboCount > _maxCombo) _maxCombo = _comboCount;

        int points = 2;
        if (_comboCount == 2) points += 1;
        if (_comboCount >= 3) points += 2;

        final scaledPoints = (points * widget.config.multiplier).round();

        setState(() {
          first.isMatched = true;
          card.isMatched = true;
          _pairsFound++;
          _score += scaledPoints;
          _isChecking = false;

          _addFloatingScore('+$scaledPoints', Colors.green);
        });

        HapticFeedback.mediumImpact();

        if (_pairsFound == widget.config.pairs) {
          _timer?.cancel();
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) _showResult();
          });
        }
      } else {
        // No match
        _comboCount = 0;
        _errors++;

        setState(() {
          _shakingCards.add(first.index);
          _shakingCards.add(card.index);
        });

        HapticFeedback.lightImpact();

        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          setState(() {
            first.isFlipped = false;
            card.isFlipped = false;
            _isChecking = false;
            _shakingCards.remove(first.index);
            _shakingCards.remove(card.index);
          });
        });
      }
    }
  }

  void _addFloatingScore(String text, Color color) {
    final id = _floatingScoreId++;
    _floatingScores.add(_FloatingScore(id: id, text: text, color: color));
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _floatingScores.removeWhere((s) => s.id == id);
        });
      }
    });
  }

  void _useHint() {
    if (_hintsRemaining <= 0 || _isChecking || _isPreview) return;

    // Find an unmatched pair, preferring ones the player has tried
    MemoryCard? targetCard;
    for (final card in _cards) {
      if (!card.isMatched && !card.isFlipped) {
        targetCard = card.card;
        break;
      }
    }
    if (targetCard == null) return;

    _hintsRemaining--;
    _score -= (5 * widget.config.multiplier).round();
    if (_score < 0) _score = 0;

    final pairCards =
        _cards.where((c) => c.card.id == targetCard!.id && !c.isMatched).toList();

    setState(() {
      for (final c in pairCards) {
        _hintedCardIds.add('${c.index}');
      }
    });

    HapticFeedback.lightImpact();

    // Show first card
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _hintedCardIds.clear();
      });
    });
  }

  void _useSkip() {
    if (_skipsRemaining <= 0 || _isChecking || _isPreview) return;

    // Find an unmatched pair
    MemoryCard? targetCard;
    for (final card in _cards) {
      if (!card.isMatched && !card.isFlipped) {
        targetCard = card.card;
        break;
      }
    }
    if (targetCard == null) return;

    _skipsRemaining--;
    _score -= (15 * widget.config.multiplier).round();
    if (_score < 0) _score = 0;

    final pairCards =
        _cards.where((c) => c.card.id == targetCard!.id && !c.isMatched).toList();

    setState(() {
      for (final c in pairCards) {
        c.isFlipped = true;
        c.isMatched = true;
      }
      _pairsFound++;
      // Skip doesn't break combo but doesn't add to it either
    });

    HapticFeedback.mediumImpact();

    if (_pairsFound == widget.config.pairs) {
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _showResult();
      });
    }
  }

  void _showResult({bool timedOut = false}) {
    // Calculate bonus points
    int completionBonus = timedOut ? 0 : 5;
    int perfectBonus = (_errors == 0 && !timedOut) ? 10 : 0;

    final scaledCompletion =
        (completionBonus * widget.config.multiplier).round();
    final scaledPerfect = (perfectBonus * widget.config.multiplier).round();

    final totalScore = _score + scaledCompletion + scaledPerfect;

    int stars = 0;
    if (!timedOut) {
      stars = 1;
      if (_errors <= 2) stars = 2;
      if (_errors == 0) stars = 3;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          config: widget.config,
          pairsFound: _pairsFound,
          totalPairs: widget.config.pairs,
          errors: _errors,
          elapsedSeconds: _elapsedSeconds,
          maxCombo: _maxCombo,
          pairPoints: _score,
          completionBonus: scaledCompletion,
          perfectBonus: scaledPerfect,
          totalScore: totalScore,
          stars: stars,
          timedOut: timedOut,
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  int? get _remainingSeconds {
    if (widget.config.timeLimitSeconds == null) return null;
    return widget.config.timeLimitSeconds! - _elapsedSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remainingSeconds;
    final isTimeLow = remaining != null && remaining <= 30;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Sair do jogo?'),
                content:
                    const Text('Seu progresso nesta partida sera perdido.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Continuar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text('Sair'),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text('Fase ${widget.config.phase}'),
        actions: [
          if (widget.config.timeLimitSeconds != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: isTimeLow ? Colors.red.shade200 : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(remaining ?? 0),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isTimeLow ? Colors.red.shade200 : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pares: $_pairsFound/${widget.config.pairs}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!widget.config.hasPreview || !_isPreview)
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                if (_comboCount >= 2)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Combo x$_comboCount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Preview banner
          if (_isPreview)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: const Text(
                'Memorize as cartas!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),

          // Card grid
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxCardWidth =
                            (constraints.maxWidth - (widget.config.cols - 1) * 8) /
                                widget.config.cols;
                        final maxCardHeight =
                            (constraints.maxHeight - (widget.config.rows - 1) * 8) /
                                widget.config.rows;
                        final cardSize =
                            maxCardWidth < maxCardHeight ? maxCardWidth : maxCardHeight;
                        final clampedSize = cardSize.clamp(70.0, 120.0);

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: List.generate(_cards.length, (index) {
                            final isShaking =
                                _shakingCards.contains(_cards[index].index);
                            final isHinted = _hintedCardIds
                                .contains('${_cards[index].index}');

                            return SizedBox(
                              width: clampedSize,
                              height: clampedSize,
                              child: _ShakeWrapper(
                                isShaking: isShaking,
                                child: MemoryCardWidget(
                                  gameCard: _cards[index],
                                  showHint: isHinted,
                                  onTap: () => _onCardTap(index),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),

                // Floating scores
                for (final fs in _floatingScores)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: _FloatingScoreWidget(score: fs),
                  ),
              ],
            ),
          ),

          // Bottom bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Score
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      Text(
                        '$_score',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Hint button
                  _BottomButton(
                    icon: Icons.lightbulb_outline,
                    label: 'Dica ($_hintsRemaining)',
                    enabled: _hintsRemaining > 0 && !_isChecking && !_isPreview,
                    onTap: _useHint,
                    color: Colors.amber,
                  ),

                  // Skip button
                  _BottomButton(
                    icon: Icons.skip_next,
                    label: 'Pular ($_skipsRemaining)',
                    enabled: _skipsRemaining > 0 && !_isChecking && !_isPreview,
                    onTap: _useSkip,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final Color color;

  const _BottomButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingScore {
  final int id;
  final String text;
  final Color color;

  _FloatingScore({required this.id, required this.text, required this.color});
}

class _FloatingScoreWidget extends StatefulWidget {
  final _FloatingScore score;

  const _FloatingScoreWidget({required this.score});

  @override
  State<_FloatingScoreWidget> createState() => _FloatingScoreWidgetState();
}

class _FloatingScoreWidgetState extends State<_FloatingScoreWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _position = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -50),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.translate(
          offset: _position.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Text(
              widget.score.text,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.score.color,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShakeWrapper extends StatefulWidget {
  final bool isShaking;
  final Widget child;

  const _ShakeWrapper({required this.isShaking, required this.child});

  @override
  State<_ShakeWrapper> createState() => _ShakeWrapperState();
}

class _ShakeWrapperState extends State<_ShakeWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5, end: -5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5, end: 3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 3, end: 0), weight: 1),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(_ShakeWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: widget.child,
        );
      },
    );
  }
}
