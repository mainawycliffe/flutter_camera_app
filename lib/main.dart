import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future main() async {
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(
    camera: firstCamera,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({
    Key key,
    @required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        camera: camera,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({
    Key key,
    this.title,
    @required this.camera,
  }) : super(key: key);

  final CameraDescription camera;
  final String title;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: null,
        title: Text(title),
      ),
      body: Center(
        child: Container(
          child: CameraWidget(
            camera: camera,
          ),
        ),
      ),
    );
  }
}

class CameraWidget extends StatefulWidget {
  CameraWidget({
    Key key,
    @required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    iconSize: 40,
                    icon: Icon(Icons.camera_roll),
                    onPressed: () {
                      _capture();
                    },
                  ),
                  IconButton(
                    iconSize: 60,
                    icon: Icon(Icons.camera),
                    onPressed: () {
                      _capture();
                    },
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: Icon(Icons.camera_front),
                    onPressed: () {
                      _capture();
                    },
                  )
                ],
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

      // Construct the path where the image should be saved using the path
      // package.
      final path = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      // Attempt to take a picture and log where it's been saved.
      await _controller.takePicture(path);
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }
}
