import 'package:camera_app/camera_controls.dart';
import 'package:flutter/material.dart';

class VideoRecordingControls extends StatelessWidget {
  final Function onStopRecordingBtnPressed;
  final Function onRecordVideoBtnPressed;
  final Function onPauseRecodingBtnPressed;
  final Function onResumeRecodingBtnPressed;
  final Function onSwitchCamerasBtnPressed;
  final Function onToggleCameraModeBtnPressed;
  final bool isRecording;
  final bool isRecordingPaused;

  const VideoRecordingControls({
    Key key,
    @required this.onSwitchCamerasBtnPressed,
    @required this.onPauseRecodingBtnPressed,
    @required this.onStopRecordingBtnPressed,
    @required this.onToggleCameraModeBtnPressed,
    @required this.onRecordVideoBtnPressed,
    @required this.onResumeRecodingBtnPressed,
    @required this.isRecordingPaused,
    this.isRecording = false,
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
                onRecordVideoBtnPressed();
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
                onStopRecordingBtnPressed();
              },
            ),
          SizedBox(
            width: 10,
          ),
          if (isRecording && !isRecordingPaused)
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
                onPauseRecodingBtnPressed();
              },
            ),
          if (isRecording && isRecordingPaused)
            RawMaterialButton(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.black,
              ),
              shape: new CircleBorder(),
              elevation: 2.0,
              fillColor: Colors.white,
              padding: const EdgeInsets.all(15.0),
              onPressed: () {
                onResumeRecodingBtnPressed();
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
                onToggleCameraModeBtnPressed();
              },
            ),
        ],
      ),
    );
  }
}
