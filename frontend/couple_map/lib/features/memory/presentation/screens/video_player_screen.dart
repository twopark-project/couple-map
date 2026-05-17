import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller.play();
        }
      });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _downloadVideo() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final dir = await getTemporaryDirectory();
      final ext = widget.videoUrl.split('.').last.split('?').first;
      final path = '${dir.path}/vestige_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await Dio().download(widget.videoUrl, path);
      await Gal.putVideo(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('동영상이 저장되었어요!', style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFFF8E8E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했어요')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          children: [
            // 비디오
            Center(
              child: _isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),

            // 컨트롤 오버레이
            if (_showControls) ...[
              // 상단 바
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _circleButton(Icons.close, () => Navigator.pop(context)),
                        _isSaving
                            ? Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                ),
                              )
                            : _circleButton(Icons.download, _downloadVideo),
                      ],
                    ),
                  ),
                ),
              ),

              // 하단 컨트롤
              if (_isInitialized)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 시크바
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                              activeTrackColor: const Color(0xFFFF8E8E),
                              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              value: _controller.value.position.inMilliseconds.toDouble(),
                              max: _controller.value.duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                              onChanged: (v) {
                                _controller.seekTo(Duration(milliseconds: v.toInt()));
                              },
                            ),
                          ),
                          // 시간 + 재생/일시정지
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_controller.value.position),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                },
                                child: Icon(
                                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              Text(
                                _formatDuration(_controller.value.duration),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
