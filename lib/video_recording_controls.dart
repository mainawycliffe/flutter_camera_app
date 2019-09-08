import 'package:flutter/material.dart';

class VideoRecordingControls extends StatelessWidget {
  final Function stop;
  final Function recordVideo;
  final Function pause;
  final Function switchCameras;
  final Function toggleCameraMode;
  final bool isRecording;

  const VideoRecordingControls({
    Key key,
    @required this.switchCameras,
    @required this.pause,
    @required this.stop,
    this.isRecording = false,
    @required this.toggleCameraMode,
    @required this.recordVideo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SwitchCamerasButton(
            onSwitchCamerasBtnPressed: onSwitchCamerasBtnPressed,
          ),
          SizedBox(
            width: 10,
          ),
          if (!isRecording)
            RawMaterialButton(
              child: Icon(
                Icons.fiber_manual_record,
                color: Colors.red,
                size: 20,
              ),
              shape: new CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: EdgeInsets.all(30.0),
              onPressed: () {
                recordVideo();
              },
            ),
          if (isRecording)
            RawMaterialButton(
              child: Icon(
                Icons.stop,
                color: Colors.red,
                size: 40,
              ),
              shape: new CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: EdgeInsets.all(20.0),
              onPressed: () {
                stop();
              },
            ),
          SizedBox(
            width: 10,
          ),
          if (isRecording)
            RawMaterialButton(
              child: Icon(
                Icons.pause,
                color: Colors.black,
              ),
              shape: new CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(15.0),
              onPressed: () {
                pause();
              },
            ),
          if (!isRecording)
            RawMaterialButton(
              child: Icon(
                Icons.camera_alt,
                color: Colors.black,
              ),
              shape: new CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(15.0),
              onPressed: () {
                toggleCameraMode();
              },
            ),
        ],
      ),
    );
  }
}
