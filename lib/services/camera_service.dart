import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class CameraStatus {
  final int total;
  final int occupied;
  final int free;

  const CameraStatus({
    required this.total,
    required this.occupied,
    required this.free,
  });

  bool get isFull => free == 0 && total > 0;

  factory CameraStatus.fromJson(Map<String, dynamic> json) {
    return CameraStatus(
      total: (json['total'] as num).toInt(),
      occupied: (json['occupied'] as num).toInt(),
      free: (json['free'] as num).toInt(),
    );
  }
}

class CameraService {
  static Future<CameraStatus> fetchStatus() async {
    final response = await http
        .get(Uri.parse('$kCameraUrl/?getstatus'))
        .timeout(const Duration(seconds: 3));

    if (response.statusCode != 200) {
      throw Exception('ESP32 retornou ${response.statusCode}');
    }

    return CameraStatus.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static String frameUrl() {
    return '$kCameraUrl/?getstill=${DateTime.now().millisecondsSinceEpoch}';
  }
}
