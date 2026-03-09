import 'package:flutter/material.dart';
import 'models.dart';
import 'game_data.dart';
import 'storage.dart';
import 'game_screen.dart';

class PhaseSelectionScreen extends StatefulWidget {
  const PhaseSelectionScreen({super.key});

  @override
  State<PhaseSelectionScreen> createState() => _PhaseSelectionScreenState();
}

class _PhaseSelectionScreenState extends State<PhaseSelectionScreen> {
  MemoryGameProgress? _progress;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await MemoryGameStorage.loadProgress();
    setState(() {
      _progress = progress;
    });
  }

  String _themeLabel(MemoryTheme theme) => switch (theme) {
        MemoryTheme.frutas => 'Frutas',
        MemoryTheme.animais => 'Animais',
        MemoryTheme.misto => 'Misto',
      };

  String _themeEmoji(MemoryTheme theme) => switch (theme) {
        MemoryTheme.frutas => '\u{1F34E}',
        MemoryTheme.animais => '\u{1F431}',
        MemoryTheme.misto => '\u{1F3B2}',
      };

  @override
  Widget build(BuildContext context) {
    if (_progress == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Jogo da Memoria'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: phases.length,
          itemBuilder: (context, index) {
            final config = phases[index];
            final isUnlocked = config.phase <= _progress!.currentPhase;
            final best = _progress!.best[config.phase];

            return _PhaseCard(
              config: config,
              isUnlocked: isUnlocked,
              best: best,
              themeLabel: _themeLabel(config.theme),
              themeEmoji: _themeEmoji(config.theme),
              onTap: isUnlocked
                  ? () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(config: config),
                        ),
                      );
                      _loadProgress();
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final PhaseConfig config;
  final bool isUnlocked;
  final PhaseResult? best;
  final String themeLabel;
  final String themeEmoji;
  final VoidCallback? onTap;

  const _PhaseCard({
    required this.config,
    required this.isUnlocked,
    this.best,
    required this.themeLabel,
    required this.themeEmoji,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isUnlocked)
                Icon(
                  Icons.lock,
                  size: 32,
                  color: Colors.grey.shade400,
                ),
              if (!isUnlocked) const SizedBox(height: 8),
              Text(
                'FASE ${config.phase}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? const Color(0xFF2E7D32) : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$themeEmoji $themeLabel',
                style: TextStyle(
                  fontSize: 14,
                  color: isUnlocked ? Colors.grey.shade700 : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${config.pairs} pares',
                style: TextStyle(
                  fontSize: 13,
                  color: isUnlocked ? Colors.grey.shade600 : Colors.grey,
                ),
              ),
              if (config.timeLimitSeconds != null)
                Text(
                  '${config.timeLimitSeconds! ~/ 60} min',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                  ),
                ),
              const SizedBox(height: 8),
              if (isUnlocked && best != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Icon(
                      i < best!.stars ? Icons.star : Icons.star_border,
                      size: 24,
                      color: Colors.amber,
                    );
                  }),
                )
              else if (isUnlocked)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (_) {
                    return const Icon(
                      Icons.star_border,
                      size: 24,
                      color: Colors.grey,
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
