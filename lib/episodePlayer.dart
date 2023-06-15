import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elflix/episode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class episodePlayer extends StatefulWidget {
   String? videoUrl;
   dynamic episode;
   

  
  episodePlayer({ 
      this.videoUrl,
      this.episode, 
    });

  @override
  State<episodePlayer> createState() => _episodePlayerState();
}

class _episodePlayerState extends State<episodePlayer> {
  late VideoPlayerController _controller;
  ChewieController? chewieController;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? userid;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    setState(() {
      userid = auth.currentUser?.uid;
    });
   //continue watching  
   
    // firestore.collection('user').doc(userid).collection('watchedVideos').doc(widget.episode['id']);
  }
 
  void _initPlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl ?? '')..initialize();
    chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.white30,
        backgroundColor: Colors.black, 
      )
    );
  }
  void _pauseVideo() async {
    final currentPosition = await _controller.position;
    final currentPositionMillis = currentPosition?.inMilliseconds;
    _controller.pause();
    if (userid != null) {
      firestore.collection('user').doc(userid).collection('watchedVideos').doc(widget.episode['id']).set({
      'playbackTime': currentPositionMillis,
      'id': widget.episode['id'],
      },SetOptions(merge: true));
    }
  }
  //   _savePositionLocally(currentPositionMillis!);
  // }

  // Future<void> _savePositionLocally(int position) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt('video_position', position);

  //   if (prefs.containsKey('video_position')) {
  //     final savedPosition = prefs.getInt('video_position');
  //     print('Saved position: $savedPosition');
  //   } else {
  //     print('Position not saved.');
  //   }
  // }
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.dispose();
    chewieController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Chewie(
            controller: chewieController!,  
            
          ),
          Positioned(
            left: 10,
            top:5,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context,
                  MaterialPageRoute(
                    builder: (context) => episode(
                      description: '',
                      imageUrl: '',
                      seriesName: '',
                    )
                  ),
                );
              },
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
            )
          )
        ],
      ),
    );
  }
}
