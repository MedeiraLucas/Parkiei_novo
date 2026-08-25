import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants.dart';
import 'camera_service.dart';

/// Singleton que mantém uma conexão WebSocket com o backend.
/// Ao receber uma mensagem, emite um CameraStatus no [statusStream].
/// Reconecta automaticamente em caso de falha.
class RealtimeService {
  RealtimeService._();
  static final RealtimeService instance = RealtimeService._();

  final _controller = StreamController<CameraStatus>.broadcast();
  Stream<CameraStatus> get statusStream => _controller.stream;

  WebSocketChannel? _channel;
  bool _disposed = false;

  void connect() {
    if (_disposed) return;
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('${kApiBaseUrl.replaceFirst('http', 'ws')}/ws'),
      );
      _channel!.stream.listen(
        _onMessage,
        onDone: _reconnect,
        onError: (_) => _reconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _reconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final vacancies = (data['vacancies'] as num?)?.toInt() ?? 1;
      final occupied = (data['occupiedSpots'] as num?)?.toInt() ?? 0;
      final free = vacancies - occupied;
      _controller.add(CameraStatus(
        total: vacancies,
        occupied: occupied,
        free: free < 0 ? 0 : free,
      ));
    } catch (_) {}
  }

  void _reconnect() {
    if (_disposed) return;
    _channel?.sink.close();
    Future.delayed(const Duration(seconds: 2), connect);
  }

  void dispose() {
    _disposed = true;
    _channel?.sink.close();
    _controller.close();
  }
}
