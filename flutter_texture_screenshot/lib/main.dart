import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Texture Screenshot',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Texture Widget Screenshot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  VideoPlayerController _controller;
  String url =
      "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

  AnimationController animationController;
  Animatable<Color> background = TweenSequence<Color>(
    [
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.red,
          end: Colors.green,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.green,
          end: Colors.blue,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.blue,
          end: Colors.pink,
        ),
      ),
    ],
  );

  GlobalKey topCaptureKey = GlobalKey();
  GlobalKey midCaptureKey = GlobalKey();
  Uint8List capturedPngData;

  capture(GlobalKey key) async {
    print(
        (key == topCaptureKey) ? "____top capture____" : "____mid capture____");
    final RenderRepaintBoundary boundary =
        key.currentContext.findRenderObject();
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    setState(() {
      final pngBytes = byteData.buffer.asUint8List();
      capturedPngData = pngBytes;
    });
  }

  void animateColor() {
    animationController.forward();
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {});
      });

    animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xff1c1c1c),
                      border: Border.all(color: Colors.cyanAccent, width: 3),
                    ),
                    child: Center(
                      child: _controller.value.initialized
                          ? AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: RepaintBoundary(
                                key: topCaptureKey,
                                child: Texture(
                                  textureId: _controller.textureId,
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      width: 150,
                      height: 20,
                      color: Colors.white54,
                      child: Center(
                        child: FittedBox(child: Text(" TOP CAPTURE ")),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 3,
              child: Stack(
                children: [
                  RepaintBoundary(
                    key: midCaptureKey,
                    child: AnimatedBuilder(
                        animation: animationController,
                        builder: (context, child) {
                          return Container(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            decoration: BoxDecoration(
                              color: background.evaluate(AlwaysStoppedAnimation(
                                  animationController.value)),
                              border: Border.all(
                                  color: Colors.cyanAccent, width: 3),
                            ),
                          );
                        }),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      width: 150,
                      height: 20,
                      color: Colors.white54,
                      child: Center(
                        child: FittedBox(child: Text(" MIDDLE CAPTURE ")),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    child: Center(
                      child: Text("EMPTY"),
                    ),
                  ),
                  Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.cyanAccent, width: 3),
                    ),
                    child: (capturedPngData != null)
                        ? Image.memory(
                            capturedPngData,
                            fit: BoxFit.none,
                          )
                        : Container(
                            color: Colors.transparent,
                          ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      width: 250,
                      height: 20,
                      color: Colors.white54,
                      child: Center(
                        child: FittedBox(
                            child: Text(" PREVIEW CAPTURED SCREENSHOT HERE")),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                color: Colors.blueGrey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: FittedBox(
                          child: RaisedButton.icon(
                              onPressed: () async {
                                await capture(topCaptureKey);
                              },
                              icon: Icon(Icons.arrow_upward),
                              label: Text("Top Capture"))),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: FittedBox(
                          child: RaisedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              },
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                              label: Text(_controller.value.isPlaying
                                  ? "Pause"
                                  : "Play"))),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: FittedBox(
                          child: RaisedButton.icon(
                              onPressed: () async {
                                await capture(midCaptureKey);
                              },
                              icon: Icon(Icons.arrow_upward),
                              label: Text("Mid Capture"))),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
