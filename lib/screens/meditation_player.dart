
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MeditationVideoPage extends StatefulWidget {
  final String videoUrl;

  const MeditationVideoPage({super.key, required this.videoUrl});

  @override
  State<MeditationVideoPage> createState() => _MeditationVideoPageState();
}

class _MeditationVideoPageState extends State<MeditationVideoPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    debugPrint('Extracted Video ID: $videoId'); // Debugging

    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        forceHD: true,
        isLive: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('360° Meditation')),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          onEnded: (error) {
            debugPrint('YouTube Player Error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading video: $error')),
            );
          },
        ),
        builder: (context, player) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Relax and immerse in 360°",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: player,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
