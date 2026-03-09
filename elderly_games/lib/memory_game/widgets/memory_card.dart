import 'dart:math';
import 'package:flutter/material.dart';
import '../models.dart';

class MemoryCardWidget extends StatefulWidget {
  final GameCard gameCard;
  final VoidCallback onTap;
  final bool showHint;

  const MemoryCardWidget({
    super.key,
    required this.gameCard,
    required this.onTap,
    this.showHint = false,
  });

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _showFront = widget.gameCard.isFlipped || widget.gameCard.isMatched;
    if (_showFront) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldShowFront =
        widget.gameCard.isFlipped || widget.gameCard.isMatched;
    if (shouldShowFront != _showFront) {
      _showFront = shouldShowFront;
      if (_showFront) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.gameCard.isMatched ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, _) {
          final angle = _flipAnimation.value * pi;
          final isFront = angle > pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildFront(),
                  )
                : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final card = widget.gameCard;
    return Container(
      decoration: BoxDecoration(
        color: card.isMatched
            ? Colors.green.shade50
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: card.isMatched
              ? Colors.green.shade400
              : widget.showHint
                  ? Colors.amber.shade600
                  : Colors.grey.shade300,
          width: widget.showHint ? 3 : 2,
        ),
        boxShadow: [
          if (widget.showHint)
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: card.isMatched ? 0.7 : 1.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.card.emoji,
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 4),
            Text(
              card.card.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E7D32),
            const Color(0xFF1B5E20),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.showHint ? Colors.amber.shade600 : const Color(0xFF1B5E20),
          width: widget.showHint ? 3 : 2,
        ),
        boxShadow: [
          if (widget.showHint)
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.question_mark_rounded,
          size: 32,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

