import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      final uri = Uri.parse(widget.audioUrl);
      final ext = uri.path.split('.').last.toLowerCase();
      final mimeMap = {
        'mp3': 'audio/mpeg',
        'wav': 'audio/wav',
        'aac': 'audio/aac',
        'm4a': 'audio/mp4',
        'ogg': 'audio/ogg',
        'flac': 'audio/flac',
      };
      final source = AudioSource.uri(
        uri,
        headers: {
          'Content-Type': mimeMap[ext] ?? 'audio/mpeg',
        },
      );
      final duration = await _player.setAudioSource(source);
      if (duration != null && mounted) {
        setState(() {
          _duration = duration;
          _isLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('AudioPlayer init error: $e');
      debugPrint('URL: ${widget.audioUrl}');
    }

    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state.playing);
        if (state.processingState == ProcessingState.completed) {
          _player.seek(Duration.zero);
          _player.pause();
        }
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _toggle() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  double get _progress {
    if (_duration.inMilliseconds == 0) return 0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  void _onSeek(Offset localPosition, double width) {
    final ratio = (localPosition.dx / width).clamp(0.0, 1.0);
    final seekPos = Duration(milliseconds: (_duration.inMilliseconds * ratio).toInt());
    _player.seek(seekPos);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE8E4)),
      ),
      child: Row(
        children: [
          // 재생 버튼
          GestureDetector(
            onTap: _isLoaded ? _toggle : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF8E8E), Color(0xFFFF7A7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 파형
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) => _onSeek(details.localPosition, constraints.maxWidth),
                  onHorizontalDragUpdate: (details) => _onSeek(details.localPosition, constraints.maxWidth),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, 28),
                    painter: _WaveformProgressPainter(progress: _progress),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // 시간
          Text(
            _isLoaded
                ? (_isPlaying || _position > Duration.zero
                    ? _formatDuration(_position)
                    : _formatDuration(_duration))
                : '--:--',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFAAAAAA),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformProgressPainter extends CustomPainter {
  final double progress;

  _WaveformProgressPainter({required this.progress});

  static const _heights = [
    0.55, 0.85, 0.40, 0.95, 0.30, 0.75, 0.90, 0.35, 0.60, 0.45,
    0.80, 0.50, 1.00, 0.40, 0.70, 0.55, 0.30, 0.65, 0.85, 0.45,
    0.35, 0.75, 0.50, 0.90, 0.40, 0.60, 0.80, 0.35, 0.70, 0.55,
    0.95, 0.45, 0.65, 0.85, 0.50, 0.75, 0.40, 0.60, 0.90, 0.55,
  ];

  static const _activeColor = Color(0xFFFF8E8E);
  static const _inactiveColor = Color(0xFFFFD6D6);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const spacing = 5.5;
    final barCount = (size.width / spacing).floor();
    final progressX = size.width * progress;

    for (int i = 0; i < barCount; i++) {
      final x = i * spacing + 1.5;
      final h = _heights[i % _heights.length] * size.height;
      final top = (size.height - h) / 2;

      paint.color = x <= progressX ? _activeColor : _inactiveColor;
      canvas.drawLine(Offset(x, top), Offset(x, top + h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
