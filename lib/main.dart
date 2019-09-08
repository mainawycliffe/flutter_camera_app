import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audio_cache.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/camera_controls.dart';
import 'package:camera_app/permission.dart';
import 'package:camera_app/video_recording_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future main() async {
  final cameras = await availableCameras();

  runApp(MyApp(
    cameras: cameras,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({
    Key key,
    @required this.cameras,
  }) : super(key: key);

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(cameras: cameras),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, @required this.cameras}) : super(key: key);

  final List<CameraDescription> cameras;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: CameraWidget(
            cameras: cameras,
          ),
        ),
      ),
    );
  }
}

class CameraWidget extends StatefulWidget {
  CameraWidget({
    Key key,
    @required this.cameras,
  }) : super(key: key);

  final List<CameraDescription> cameras;

  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool _isVideoRecordingMode = false;
  bool _isRecording = false;

  static AudioCache audioPlayer = AudioCache(respectSilence: true);

  @override
  void initState() {
    super.initState();

    // To display the current output from the camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.cameras.first,
      // Define the resolution to use - from low - max (highest resolution available).
      ResolutionPreset.max,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        if (!_isVideoRecordingMode)
                          CameraControls(
                            recordVideo: () {
                              setState(() {
                                _isVideoRecordingMode = true;
                              });
                            },
                            takePicture: _capture,
                            switchCameras: () {},
                          ),
                        if (_isVideoRecordingMode)
                          VideoRecordingControls(
                            switchCameras: () {},
                            pause: () {},
                            stop: () {
                              setState(() {
                                _isRecording = false;
                              });
                            },
                            isRecording: _isRecording,
                            switchToStillPhotos: () {
                              setState(() {
                                _isVideoRecordingMode = false;
                              });
                            },
                            recordVideo: () {
                              setState(() {
                                _isRecording = true;
                              });
                            },
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _capture() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      await _controller.takePicture(path);

      await audioPlayer.play("shutter.wav");

      // attempt to save to gallery
      bool hasPermission =
          await PermissionsService().hasGalleryWritePermission();

      // request for permision if not given
      if (!hasPermission) {
        bool isGranted =
            await PermissionsService().requestPermissionToGallery();

        if (!isGranted) {
          return;
        }
      }

      var image = await File(path).readAsBytes();

      var y = Uint8List.fromList(image);

      await ImageGallerySaver.saveImage(y);
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }
}
