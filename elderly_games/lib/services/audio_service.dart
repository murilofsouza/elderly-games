import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  bool get isEnabled => _enabled;

  void enable() => _enabled = true;
  void disable() => _enabled = false;
  void toggle() => _enabled = !_enabled;

  Future<void> playTap() => _play('audio/tap.mp3');
  Future<void> playCorrect() => _play('audio/correct.mp3');
  Future<void> playWrong() => _play('audio/wrong.mp3');
  Future<void> playPoints() => _play('audio/points.mp3');
  Future<void> playGameOver() => _play('audio/game_over.mp3');
  Future<void> playLevelUp() => _play('audio/level_up.mp3');

  Future<void> _play(String asset) async {
    if (!_enabled) return;
    try {
      await _player.play(AssetSource(asset));
    } catch (_) {
      // Asset not found or playback error — fail silently.
    }
  }

  void dispose() => _player.dispose();
}
