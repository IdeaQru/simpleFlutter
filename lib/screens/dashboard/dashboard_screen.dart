import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../../constants.dart';
import 'components/header.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/linechart/linechart.dart';
import 'package:admin/screens/gauge/speedogauge.dart';
import 'package:admin/controllers/ws_controller.dart'; // WebSocket service

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Stream<String> getTime() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      yield DateFormat('HH:mm:ss').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "SIMPEL DASHBOARD",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          StreamBuilder<String>(
            stream: getTime(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data!,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                );
              } else {
                return Text(
                  "Loading...",
                  style: TextStyle(fontSize: 24),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<FlSpot> dataPoints = []; // Simpan data untuk grafik
  double currentSpeed = 0.0; // Simpan data untuk speedometer
  WebSocketService _wsService = WebSocketService(); // Instance WebSocket Service

  @override
  void initState() {
    super.initState();

    // Memulai koneksi WebSocket
    _wsService.startListening('ws://192.168.47.111:12345'); // Sesuaikan URL dengan server WebSocket

    // Mendengarkan data dari WebSocket dan memperbarui UI
    _wsService.onDataReceived.listen((data) {
      _updatePosition(data); // Memproses data yang diterima dari WebSocket
    });
  }

// Fungsi untuk memperbarui posisi marker dan data lainnya
  void _updatePosition(Map<String, String> data) {
    print("Data diterima: $data");

    try {
      // Parsing data latitude dan longitude

      // Parsing speed untuk ditampilkan di speedometer
      double speed = double.tryParse(data['speed'] ?? '') ?? 0.0;

      setState(() {
        // Update grafik dan speedometer
        currentSpeed = speed; // Untuk speedometer
        double newX = dataPoints.isEmpty ? 0 : dataPoints.last.x + 1;
        dataPoints.add(FlSpot(newX, speed)); // Menambahkan data ke grafik
        if (dataPoints.length > 10) {
          dataPoints.removeAt(
              0); // Menghapus data lama untuk menjaga grafik tetap rapi
        }
      });
    } catch (e) {
      print("Error parsing data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 15,
                  child: Column(
                    children: [
                      WelcomeScreen(), // Memanggil WelcomeScreen di sini
                      SizedBox(height: 10),
                      LineChartSample(
                          dataPoints: dataPoints), // Grafik untuk speed
                      SizedBox(height: 10),
                      Speedometer(
                          speedValue: currentSpeed), // Speedometer untuk speed
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
