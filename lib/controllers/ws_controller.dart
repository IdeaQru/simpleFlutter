import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;

  // StreamControllers
  StreamController<Map<String, String>> _dataStreamController =
      StreamController<Map<String, String>>.broadcast();
  StreamController<double> _speedStreamController =
      StreamController<double>.broadcast();
  StreamController<Map<String, double>> _locationStreamController =
      StreamController<Map<String, double>>.broadcast();

  // Stream untuk kecepatan
  Stream<double> get speedStream => _speedStreamController.stream;

  // Stream untuk data yang diterima
  Stream<Map<String, String>> get onDataReceived =>
      _dataStreamController.stream;

  // Stream untuk lokasi (latitude dan longitude)
  Stream<Map<String, double>> get locationStream => _locationStreamController.stream;

  // Fungsi untuk memulai listening di WebSocket
  Future<void> startListening(String serverUrl) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));

      print("Connected to WebSocket server at $serverUrl");

      // Mendengarkan setiap pesan yang diterima dari WebSocket
      _channel!.stream.listen((message) {
        print("Message received: $message");

        try {
          // Parsing data JSON
          Map<String, dynamic> data = jsonDecode(message);
          print("Parsed JSON: $data");

          // Memastikan semua kunci yang diharapkan ada
          if (_validateData(data)) {
            // Memproses data
            _processData(data);
          } else {
            print("Invalid data format: missing required keys.");
          }
        } catch (e) {
          print("Error parsing JSON: $e");
        }
      }, onError: (error) {
        print("WebSocket error: $error");
      }, onDone: () {
        print("WebSocket connection closed.");
      });
    } catch (e) {
      print("Error connecting to WebSocket: $e");
    }
  }

  // Fungsi untuk memproses data yang diterima
  void _processData(Map<String, dynamic> data) {
    // Masukkan data ke dalam Map
    Map<String, String> dataMap = {
      'time': data['time'].toString(),
      'date': data['date'].toString(),
      'latitude': data['latitude'].toString(),
      'longitude': data['longitude'].toString(),
      'altitude': data['altitude'].toString(),
      'speed': data['speed'].toString(),
      'course': data['course'].toString(),
      'satellite': data['satellite'].toString(),
      'roll': data['roll'].toString(),
      'pitch': data['pitch'].toString(),
      'yaw': data['yaw'].toString(),
      'depth': data['depth'].toString(),
    };

    // Tambahkan data ke stream data
    _dataStreamController.add(dataMap);
    print("Data map successfully added to stream: $dataMap");

    // Jika ada data kecepatan (speed), tambahkan ke stream speed
    if (data.containsKey('speed')) {
      double speed = double.tryParse(data['speed'].toString()) ?? 0.0;
      _speedStreamController.add(speed);
    }

    // Jika ada data latitude dan longitude, tambahkan ke stream lokasi
    if (data.containsKey('latitude') && data.containsKey('longitude')) {
      double latitude = double.tryParse(data['latitude'].toString()) ?? 0.0;
      double longitude = double.tryParse(data['longitude'].toString()) ?? 0.0;
      _locationStreamController.add({'latitude': latitude, 'longitude': longitude});
    }
  }

  // Fungsi untuk validasi data
  bool _validateData(Map<String, dynamic> data) {
    return data.containsKey('time') &&
        data.containsKey('date') &&
        data.containsKey('latitude') &&
        data.containsKey('longitude') &&
        data.containsKey('altitude') &&
        data.containsKey('speed') &&
        data.containsKey('course') &&
        data.containsKey('satellite') &&
        data.containsKey('roll') &&
        data.containsKey('pitch') &&
        data.containsKey('yaw') &&
        data.containsKey('depth');
  }

  // Fungsi untuk mengirim pesan ke server WebSocket
  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
      print("Message sent: $message");
    } else {
      print("WebSocket is not connected.");
    }
  }

  // Fungsi untuk menutup WebSocket
  void dispose() {
    if (_channel != null) {
      print("Closing WebSocket connection.");
      _channel!.sink.close(status.goingAway);
    }
    _dataStreamController.close();
    _speedStreamController.close();
    _locationStreamController.close();
  }
}
