import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:admin/controllers/ws_controller.dart'; // Pastikan ini mengarah ke lokasi WebSocketService

class SpeedometerScreen extends StatefulWidget {
  @override
  _SpeedometerScreenState createState() => _SpeedometerScreenState();
}

class _SpeedometerScreenState extends State<SpeedometerScreen> {
  late WebSocketService _webSocketService;
  String latitudeDMS = 'N/A'; // Inisialisasi awal
  String longitudeDMS = 'N/A'; // Inisialisasi awal

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService();
    _webSocketService.startListening('ws://192.168.47.111:12345');

    // Listener untuk data lokasi (latitude, longitude)
    _webSocketService.locationStream.listen((locationData) {
      // Verifikasi data yang diterima dari WebSocket
      print('Data lokasi diterima: $locationData');
      
      if (locationData.containsKey('latitude') && locationData.containsKey('longitude')) {
        setState(() {
          // Konversi ke DMS
          latitudeDMS = _convertToDMS(locationData['latitude']!, true);
          longitudeDMS = _convertToDMS(locationData['longitude']!, false);
        });
      } else {
        print('Data latitude atau longitude tidak tersedia.');
      }
    });
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

  // Fungsi untuk mengonversi Decimal Degrees ke DMS
  String _convertToDMS(double decimalDegree, bool isLatitude) {
    String direction = '';
    if (isLatitude) {
      direction = decimalDegree >= 0 ? 'N' : 'S';
    } else {
      direction = decimalDegree >= 0 ? 'E' : 'W';
    }

    double absValue = decimalDegree.abs();
    int degrees = absValue.floor();
    double minutesDecimal = (absValue - degrees) * 60;
    int minutes = minutesDecimal.floor();
    double seconds = (minutesDecimal - minutes) * 60;

    print('Konversi DMS: $degrees°$minutes\'${seconds.toStringAsFixed(2)}"$direction');
    return '$degrees°$minutes\'${seconds.toStringAsFixed(2)}"$direction';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speedometer'),
      ),
      body: Column(
        children: [
          // Geser gauge ke atas dengan padding
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Center(
              child: StreamBuilder<double>(
                stream: _webSocketService.speedStream,
                initialData: 0.0, // Nilai awal kecepatan
                builder: (context, snapshot) {
                  double speedValue = snapshot.data ?? 0.0;
                  return Speedometer(speedValue: speedValue);
                },
              ),
            ),
          ),
          // Bagian menampilkan lokasi dan koordinat dalam DMS
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 20.0), // Jarak antar elemen
            child: Column(
              children: [
                Text(
                  'Latitude: $latitudeDMS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Longitude: $longitudeDMS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Speedometer extends StatelessWidget {
  final double speedValue;

  Speedometer({required this.speedValue});

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 100,
          ranges: <GaugeRange>[
            GaugeRange(startValue: 0, endValue: 50, color: Colors.green),
            GaugeRange(startValue: 50, endValue: 80, color: Colors.orange),
            GaugeRange(startValue: 80, endValue: 100, color: Colors.red),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(value: speedValue),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Container(
                child: Text(
                  '$speedValue km/h',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              angle: 90,
              positionFactor: 0.5,
            ),
          ],
        ),
      ],
    );
  }
}
