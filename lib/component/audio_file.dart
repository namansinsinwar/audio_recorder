import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioFile extends StatefulWidget {
  const AudioFile({Key key, @required this.path}) : super(key: key);
  final String path;

  @override
  _AudioFileState createState() => _AudioFileState();
}

class _AudioFileState extends State<AudioFile> {
  AudioPlayer advancePlayer;
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;

  @override
  void initState() {
    advancePlayer = AudioPlayer();
    advancePlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });

    advancePlayer.onAudioPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });
    advancePlayer.onPlayerCompletion.listen((event) {
      setState(() {
        isPlaying = false;
        _position = Duration.zero;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          _getButton(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _position.toString().split('.')[0].substring(3),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              _getSlider(),
            ],
          )
        ],
      ),
    );
  }

  Widget _getSlider() {
    return Slider(
      value: _position.inSeconds.toDouble(),
      onChanged: (double value) {
        setState(() {
          changeToSecond(value.toInt());
        });
      },
      min: 0.0,
      max: _duration.inSeconds.toDouble(),
      activeColor: Colors.white,
      inactiveColor: Colors.grey,
    );
  }

  void changeToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    advancePlayer.seek(newDuration);
  }

  Widget _getButton() {
    return MaterialButton(
      onPressed: () {
        if (isPlaying) {
          advancePlayer.pause();
          setState(() {
            isPlaying = false;
          });
        } else {
          advancePlayer.play(widget.path);
          setState(() {
            isPlaying = true;
          });
        }
      },
      child: isPlaying
          ? Icon(
              Icons.pause,
              color: Colors.white,
              size: 32,
            )
          : Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
    );
  }
}
