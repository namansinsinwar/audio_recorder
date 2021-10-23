import 'package:audio_recorder/component/audio_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart' show DateFormat;
import 'dart:async';
import 'dart:io';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterSoundRecorder _myRecorder;
  String filePath;
  bool _play = false;
  String _recorderTxt = '0:00';

  List<String> pathToAllAudioFile = [];
  double iconSize = 20;
  double boxSize = 50;
  int acceptedData = 0;
  ValueNotifier<double> valueListenerHorizontal = ValueNotifier(.0);
  bool longPressPushed = false;
  bool audioLocked = false;

  @override
  void initState() {
    super.initState();
    valueListenerHorizontal.value = 0.5;
    startIt();
  }

  void startIt() async {
    _myRecorder = FlutterSoundRecorder();
    await initializeDateFormatting();

    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: const Color(0xffe2d7d2),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _getTimer(),
            SizedBox(
              height: 20,
            ),
            _getSliderButton(),
            Expanded(
              child: ListView.builder(
                itemCount: pathToAllAudioFile.length,
                itemBuilder: (context, index) {
                  return AudioFile(path: pathToAllAudioFile[index]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> record() async {
    filePath =
        '/sdcard/Download/${DateFormat('yyyyMMddkkmmss').format(DateTime.now())}.wav';
    pathToAllAudioFile.add(filePath);
    Directory dir = Directory(path.dirname(filePath));
    if (!dir.existsSync()) {
      dir.createSync();
    }
    _myRecorder.openAudioSession();
    await _myRecorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
    );

    _myRecorder.onProgress.listen((e) {
      var date = DateTime.fromMillisecondsSinceEpoch(e.duration.inMilliseconds,
          isUtc: true);
      var txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

      setState(() {
        _recorderTxt = txt.substring(1, 5);
      });
    });
    // _recorderSubscription.cancel();
  }

  Future<String> stopRecord() async {
    _myRecorder.closeAudioSession();
    return await _myRecorder.stopRecorder();
  }

  Widget _getTimer() {
    return Container(
      height: 300.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 2, 199, 226),
            Color.fromARGB(255, 6, 75, 210)
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.elliptical(MediaQuery.of(context).size.width, 100.0),
        ),
      ),
      child: Center(
        child: Text(
          _recorderTxt,
          style: TextStyle(fontSize: 70),
        ),
      ),
    );
  }

  Widget _getSliderButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          Column(
            children: [
              Visibility(
                visible: longPressPushed,
                child: const Text(
                  "Swipe right to lock the audio",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              _getBuilder(),
              SizedBox(height: 8,),
              Text(
                longPressPushed ? "" : audioLocked ? "Tap to stop" : "Hold to record",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getBuilder() {
    return Builder(
      builder: (context) {
        final handle = GestureDetector(
          onLongPressStart: (_) {
            record();
            setState(() {
              longPressPushed = true;
              boxSize = 80;
            });
          },
          onLongPressMoveUpdate: (details) {
            valueListenerHorizontal.value =
                ((details.offsetFromOrigin.dx + context.size.width / 2) /
                        context.size.width)
                    .clamp(0, 1.0);
            if(valueListenerHorizontal.value == 1){
              audioLocked = true;
            }
          },
          onLongPressEnd: (_) async {
            if(!audioLocked){
              await stopRecord();
            }
            setState(() {
              _recorderTxt = '0:00';
              longPressPushed = false;
              boxSize = 50;
              valueListenerHorizontal.value = 0.5;
            });
          },
          onTap: () {
            if(!audioLocked){
              record();
            } else{
              stopRecord();
              _recorderTxt = '0:00';
              setState(() {
                audioLocked = false;
              });
            }
          },
          child: _getIcon(),
        );

        return AnimatedBuilder(
          animation: valueListenerHorizontal,
          builder: (context, child) {
            return Align(
              alignment: Alignment(valueListenerHorizontal.value * 2 - 1, .5),
              child: child,
            );
          },
          child: handle,
        );
      },
    );
  }

  Widget _getIcon() {
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green,
      ),
      child: !audioLocked ? Icon(
        Icons.mic,
        color: Colors.white,
      ) : Icon(Icons.play_arrow, color: Colors.white,),
    );
  }
}
