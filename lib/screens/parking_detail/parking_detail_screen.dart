import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/parking_model.dart';
import '../../services/camera_service.dart';
import '../../services/realtime_service.dart';

class ParkingDetailScreen extends StatefulWidget {
  final ParkingModel parking;

  const ParkingDetailScreen({super.key, required this.parking});

  @override
  State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
  CameraStatus? _status;
  bool _cameraOnline = false;
  String _frameUrl = CameraService.frameUrl();
  StreamSubscription<CameraStatus>? _wsSub;
  Timer? _frameTimer;

  @override
  void initState() {
    super.initState();
    _wsSub = RealtimeService.instance.statusStream.listen((status) {
      if (mounted) setState(() { _status = status; _cameraOnline = true; });
    });
    _frameTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) setState(() => _frameUrl = CameraService.frameUrl());
    });
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _frameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        title: Text(widget.parking.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CameraFeed(frameUrl: _frameUrl, online: _cameraOnline),
            const SizedBox(height: 16),
            _StatusBanner(status: _status, online: _cameraOnline),
            const SizedBox(height: 16),
            if (_status != null) _OccupancyGrid(status: _status!),
            const SizedBox(height: 16),
            _InfoCard(parking: widget.parking),
          ],
        ),
      ),
    );
  }
}

class _CameraFeed extends StatelessWidget {
  final String frameUrl;
  final bool online;

  const _CameraFeed({required this.frameUrl, required this.online});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: online ? const Color(0xFF22c55e) : const Color(0xFF374151),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              frameUrl,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, err, trace) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, color: Colors.white24, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Câmera offline',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: online ? const Color(0xFF22c55e) : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      online ? 'AO VIVO' : 'OFFLINE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final CameraStatus? status;
  final bool online;

  const _StatusBanner({required this.status, required this.online});

  @override
  Widget build(BuildContext context) {
    if (!online || status == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1a2235),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1f2d45)),
        ),
        child: const Column(
          children: [
            Icon(Icons.wifi_off, color: Colors.white38, size: 32),
            SizedBox(height: 8),
            Text(
              'Aguardando câmera...',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final isFull = status!.isFull;
    final color = isFull ? const Color(0xFFef4444) : const Color(0xFF22c55e);
    final label = isFull ? 'LOTADO' : 'VAGA DISPONÍVEL';
    final icon = isFull ? Icons.no_transfer : Icons.check_circle_outline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _OccupancyGrid extends StatelessWidget {
  final CameraStatus status;

  const _OccupancyGrid({required this.status});

  @override
  Widget build(BuildContext context) {
    final ratio = status.total > 0 ? status.occupied / status.total : 0.0;
    final barColor = ratio >= 1.0
        ? const Color(0xFFef4444)
        : ratio >= 0.7
            ? const Color(0xFFf59e0b)
            : const Color(0xFF22c55e);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2235),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1f2d45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OCUPAÇÃO EM TEMPO REAL',
            style: TextStyle(
              color: Color(0xFF64748b),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatBox(label: 'Livres', value: '${status.free}', color: const Color(0xFF22c55e)),
              const SizedBox(width: 10),
              _StatBox(label: 'Ocupadas', value: '${status.occupied}', color: const Color(0xFFef4444)),
              const SizedBox(width: 10),
              _StatBox(label: 'Total', value: '${status.total}', color: const Color(0xFF3b82f6)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: const Color(0xFF0a0e1a),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 12),
          _SpotsGrid(status: status),
        ],
      ),
    );
  }
}

class _SpotsGrid extends StatelessWidget {
  final CameraStatus status;

  const _SpotsGrid({required this.status});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(status.total, (i) {
        final occupied = i < status.occupied;
        final color = occupied ? const Color(0xFFef4444) : const Color(0xFF22c55e);
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                occupied ? '🚗' : '⬜',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                'V${i + 1}',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF64748b), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ParkingModel parking;

  const _InfoCard({required this.parking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2235),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1f2d45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF3b82f6), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              parking.location,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          if (parking.distance != null)
            Text(
              parking.distance!,
              style: const TextStyle(
                color: Color(0xFF3b82f6),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}
