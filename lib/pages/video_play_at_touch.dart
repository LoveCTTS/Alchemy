import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayAtTouch extends StatefulWidget {


  final String message;
  VideoPlayAtTouch(this.message);
  @override
  VideoPlayAtTouchState createState() => VideoPlayAtTouchState();
}

class VideoPlayAtTouchState extends State<VideoPlayAtTouch> {

  VideoPlayerController _videoPlayerController;
  Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.network(widget.message);
    _initializeVideoPlayerFuture = _videoPlayerController.initialize().then((_){
      setState(() {
        _videoPlayerController.play();
      });
    });

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.0,
      ),
        body:GestureDetector( onTap: () {
          _videoPlayerController.value.isPlaying? _videoPlayerController.pause() : _videoPlayerController.play();
        },child:Container(

          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child:
            FutureBuilder(
             future: _initializeVideoPlayerFuture,
             builder: (context, snapshot){
               if(snapshot.connectionState == ConnectionState.done){
                 return AspectRatio(aspectRatio: _videoPlayerController.value.aspectRatio,

                   child: VideoPlayer(_videoPlayerController),
                 );
               }else {
                 return Center(child: CircularProgressIndicator());
               }
             },
            )
    )),
    floatingActionButton: FloatingActionButton(
      onPressed: (){
        setState(() {
          if(_videoPlayerController.value.isPlaying){
            _videoPlayerController.pause();
          }else {
            _videoPlayerController.play();
          }
        });
      },
      child : Icon(_videoPlayerController.value.isPlaying? Icons.pause: Icons.play_arrow)
    ),
    );
  }
}

