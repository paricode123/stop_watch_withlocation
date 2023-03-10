import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StopwatchPage extends StatefulWidget {
  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  Stopwatch _stopwatch = Stopwatch();
  String _elapsedTime = '00:00:00';
  Duration duration = Duration();
  LatLng _currentPosition = LatLng(0.0, 0.0);
  late Timer _timer;
  bool _showMapButton = false;
  GoogleMapController? _mapController;

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), _updateTimer);
  }

  void _updateTimer(Timer timer) {
    if (_stopwatch.isRunning) {
      setState(() {
        Duration duration = _stopwatch.elapsed;
        _elapsedTime =
        '${(duration.inHours % 24).toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}:${(duration.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}';
      });
    }
  }

  void _startStopwatch() {
    setState(() {
      _stopwatch.start();
      _startTimer();
      _showMapButton = false;
    });
  }

  void _stopStopwatch() async {
    setState(() {
      _stopwatch.stop();
      _timer.cancel();
      _showMapButton = true;
    });
    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);
  }

  void _resetStopwatch() {
    setState(() {
      _stopwatch.reset();
      _elapsedTime = '00:00:00';
      _showMapButton = false;
    });
  }

  Widget _createMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: _currentPosition,
        zoom: 14,
      ),
      onMapCreated: (GoogleMapController controller) {
        setState(() {
          _mapController = controller;
        });
      },
      myLocationEnabled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stopwatch'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _elapsedTime,
              style: TextStyle(fontSize: 50),
            ),
            SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: RaisedButton(
                    onPressed: _startStopwatch,
                    child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                    color: Colors.green,
                    shape: CircleBorder(),
                  ),
                ),
                SizedBox(width: 55),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: RaisedButton(
                    onPressed: _stopStopwatch,
                    child: Icon(Icons.stop, color: Colors.white, size: 30),
                    color: Colors.red,
                    shape: CircleBorder(),
                  ),
                ),
                SizedBox(width: 55),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: RaisedButton(
                    onPressed: _resetStopwatch,
                    child: Icon(Icons.refresh, color: Colors.white, size: 30),
                    color: Colors.blue,
                    shape: CircleBorder(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _showMapButton
                ? RaisedButton(
              onPressed: () async {
                final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${_currentPosition.latitude},${_currentPosition.longitude}';
                if (await canLaunch(googleMapsUrl)) {
                  await launch(googleMapsUrl);
                } else {
                  throw 'Could not launch $googleMapsUrl';
                }
              },
              child: Text('Show Map'),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}