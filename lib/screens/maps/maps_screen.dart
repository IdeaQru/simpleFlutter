import 'dart:convert';
import 'package:admin/controllers/ws_controller.dart'; // WebSocket service
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class MapsScreen extends StatefulWidget {
  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  WebSocketService _wsService = WebSocketService();
  LatLng _currentPosition = LatLng(-7.2756, 112.7976);
  String _currentTime = '';
  String _altitude = '';
  String _speed = '';
  String _course = '';
  String _satellite = '';
  String _roll = '';
  String _pitch = '';
  String _yaw = '';
  String _depth = '';

  bool _tracking = false;
  List<LatLng> _trackedPositions = [];

  @override
  void initState() {
    super.initState();
    _wsService.startListening('ws://192.168.47.111:12345');
    _wsService.onDataReceived.listen((data) {
      _updatePosition(data);
    });
  }

  String getCurrentTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  void toggleTracking() {
    setState(() {
      _tracking = !_tracking;
      if (!_tracking) {
        _trackedPositions.clear();
      }
    });
  }

  void _updatePosition(Map<String, String> data) {
    try {
      double lat = double.tryParse(data['latitude'] ?? '') ?? _currentPosition.latitude;
      double lng = double.tryParse(data['longitude'] ?? '') ?? _currentPosition.longitude;

      setState(() {
        _currentPosition = LatLng(lat, lng);
        _currentTime = data['time'] ?? getCurrentTime();
        _altitude = data['altitude'] ?? 'Unknown';
        _speed = data['speed'] ?? 'Unknown';
        _course = data['course'] ?? 'Unknown';
        _satellite = data['satellite'] ?? 'Unknown';
        _roll = data['roll'] ?? 'Unknown';
        _pitch = data['pitch'] ?? 'Unknown';
        _yaw = data['yaw'] ?? 'Unknown';
        _depth = data['depth'] ?? 'Unknown';

        if (_tracking) {
          _trackedPositions.add(_currentPosition);
        }
      });
    } catch (e) {
      print("Error updating position: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Maps with Real-Time Data"),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  // Marker untuk posisi saat ini dengan tampilan khusus
                  Marker(
                    point: _currentPosition,
                    width: 150.0,
                    height: 100.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Posisi Terkini',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$_currentTime',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ],
                    ),
                  ),
                  // Markers untuk bekas lokasi
                  ..._trackedPositions.map((position) => Marker(
                        point: position,
                        width: 10.0,
                        height: 10.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      )),
                ],
              ),
              // Polyline untuk menghubungkan posisi bekas
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _trackedPositions,
                    strokeWidth: 4.0,
                    color: Colors.green.withOpacity(0.7),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: toggleTracking,
                  child: Text(_tracking ? 'Stop Tracking' : 'Start Tracking'),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Terkini:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text('Waktu: $_currentTime', style: TextStyle(color: Colors.black)),
                      Text('Altitude: $_altitude m', style: TextStyle(color: Colors.black)),
                      Text('Speed: $_speed km/h', style: TextStyle(color: Colors.black)),
                      Text('Course: $_course°', style: TextStyle(color: Colors.black)),
                      Text('Satellite: $_satellite', style: TextStyle(color: Colors.black)),
                      Text('Roll: $_roll', style: TextStyle(color: Colors.black)),
                      Text('Pitch: $_pitch', style: TextStyle(color: Colors.black)),
                      Text('Yaw: $_yaw', style: TextStyle(color: Colors.black)),
                      Text('Depth: $_depth', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _wsService.dispose();
    super.dispose();
  }
}
