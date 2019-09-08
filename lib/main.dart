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

enum CameraMode {
  PhotosMode,
  VideoMode,
}

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
  CameraMode _cameraMode = CameraMode.PhotosMode;
  CameraDescription _currentSelectedCamera;

  String _recordedVideoSavePath;

  static AudioCache audioPlayer = AudioCache(respectSilence: true);

  @override
  void initState() {
    super.initState();
    // To display the current output from the camera,
    // create a CameraController.

    _currentSelectedCamera = widget.cameras.first;

    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      _currentSelectedCamera,
      // Define the resolution to use - from low - max (highest resolution available).
      ResolutionPreset.max,
      enableAudio: true,
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
                        if (_cameraMode == CameraMode.PhotosMode)
                          _cameraControls(context),
                        if (_cameraMode == CameraMode.VideoMode)
                          _videoRecordingControls()
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

  CameraControls _cameraControls(BuildContext context) {
    return CameraControls(
      toggleCameraMode: _toggleCameraMode,
      takePicture: () => _capture(context),
      switchCameras: _switchCamera,
    );
  }

  VideoRecordingControls _videoRecordingControls() {
    return VideoRecordingControls(
      onSwitchCamerasBtnPressed: _switchCamera,
      onPauseRecodingBtnPressed: _pauseVideoRecording,
      onStopRecordingBtnPressed: _stopVideoRecording,
      onToggleCameraModeBtnPressed: _toggleCameraMode,
      onRecordVideoBtnPressed: _startVideoRecording,
      onResumeRecodingBtnPressed: _resumeVideoRecording,
      isRecordingPaused: _controller.value.isRecordingPaused,
      isRecording: _controller.value.isRecordingVideo,
    );
  }

  Future _switchCamera() async {
    // loop through all cameras and find current camera, then move to next
    for (var camera in widget.cameras) {
      if (camera.name == _currentSelectedCamera.name) {
        var x = widget.cameras.indexOf(camera);

        setState(() {
          // if the the last camera, move to first
          if (x == widget.cameras.length - 1) {
            _currentSelectedCamera = widget.cameras.first;
          } else {
            _currentSelectedCamera = widget.cameras[x + 1];
          }
        });

        if (_controller != null) {
          await _controller.dispose();
        }

        _controller = CameraController(
          _currentSelectedCamera,
          ResolutionPreset.max,
          enableAudio: true,
        );

        // If the controller is updated then update the UI.
        _controller.addListener(() {
          if (mounted) setState(() {});
          if (_controller.value.hasError) {
            print('Camera error ${_controller.value.errorDescription}');
          }
        });

        try {
          _controller.initialize();
        } on CameraException catch (e) {
          print(e);
        }
        break;
      }
    }
  }

  Future _startVideoRecording() async {
    if (_cameraMode != CameraMode.VideoMode) {
      return;
    }

    // for iOS optimization
    _controller.prepareForVideoRecording();

    final Directory extDir = await getExternalStorageDirectory();
    final String dirPath = '${extDir.path}/Movies/recorded';
    await Directory(dirPath).create(recursive: true);
    _recordedVideoSavePath = '$dirPath/${DateTime.now()}.mp4';
    print(_recordedVideoSavePath);

    try {
      await _controller.startVideoRecording(_recordedVideoSavePath);
    } on CameraException catch (e) {
      print(e);
      return;
    }

    setState(() {});
  }

  void _pauseVideoRecording() async {
    if (_cameraMode != CameraMode.VideoMode) {
      return;
    }

    try {
      await _controller.pauseVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return;
    }

    setState(() {});
  }

  void _resumeVideoRecording() async {
    if (_cameraMode != CameraMode.VideoMode) {
      return;
    }

    try {
      await _controller.resumeVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return;
    }

    setState(() {});
  }

  void _stopVideoRecording() async {
    if (_cameraMode != CameraMode.VideoMode) {
      return;
    }

    try {
      await _controller.stopVideoRecording();
    } on CameraException catch (e) {
      print(e);
    }

    setState(() {});
  }

  void _toggleCameraMode() {
    setState(() {
      _cameraMode = _cameraMode == CameraMode.PhotosMode
          ? CameraMode.VideoMode
          : CameraMode.PhotosMode;
    });
  }

  void _capture(BuildContext context) async {
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
          _showMessage(
            context,
            "Permision Denied. Image was not saved to your Gallery!",
            color: Colors.red,
          );
          return;
        }
      }

      var image = await File(path).readAsBytes();

      var y = Uint8List.fromList(image);

      await ImageGallerySaver.saveImage(y);
    } catch (e) {
      _showMessage(
        context,
        "Error! ${e.toString()}",
        color: Colors.red,
      );
    }
  }

  /// Show snakbar message, you can customize text color for errors
  _showMessage(BuildContext context, String message,
      {Color color: Colors.white}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: color),
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }
}
