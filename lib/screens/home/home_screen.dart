import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/parking_model.dart';
import '../../services/camera_service.dart';
import '../../services/parking_service.dart';
import '../../services/realtime_service.dart';
import '../rating/rating_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isListVisible = true;

  List<ParkingModel> _parkings = [];
  bool _loading = true;
  Timer? _refreshTimer;
  StreamSubscription<CameraStatus>? _wsSub;
  CameraStatus? _cameraStatus;

  final String _darkMapStyle = '''
  [
    { "elementType": "geometry", "stylers": [ { "color": "#242f3e" } ] },
    { "elementType": "labels.text.fill", "stylers": [ { "color": "#746855" } ] },
    { "elementType": "labels.text.stroke", "stylers": [ { "color": "#242f3e" } ] },
    { "featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [ { "color": "#d59563" } ] },
    { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#d59563" } ] },
    { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "color": "#263c3f" } ] },
    { "featureType": "road", "elementType": "geometry", "stylers": [ { "color": "#38414e" } ] },
    { "featureType": "road", "elementType": "geometry.stroke", "stylers": [ { "color": "#212a37" } ] },
    { "featureType": "road", "elementType": "labels.text.fill", "stylers": [ { "color": "#9ca5b3" } ] },
    { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#746855" } ] },
    { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#17263c" } ] }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _loadParkings();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) => _loadParkings());
    _wsSub = RealtimeService.instance.statusStream.listen((status) {
      if (mounted) setState(() => _cameraStatus = status);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _wsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadParkings() async {
    final parkings = await ParkingService.fetchParkings();
    if (mounted) {
      setState(() {
        _parkings = parkings;
        _loading = false;
      });
    }
  }

  // Retorna os valores de ocupação reais: usa camera para o ID 1, model para os demais
  (int free, int total) _effectiveOccupancy(ParkingModel parking) {
    if (parking.id == 1 && _cameraStatus != null) {
      return (_cameraStatus!.free, _cameraStatus!.total);
    }
    return (parking.freeSpots, parking.vacancies);
  }

  Set<Marker> _createMarkers() {
    return _parkings
        .where((p) => p.position != null)
        .map((parking) {
          final (free, total) = _effectiveOccupancy(parking);
          return Marker(
            markerId: MarkerId(parking.id.toString()),
            position: parking.position!,
            infoWindow: InfoWindow(
              title: parking.name,
              snippet: total > 0
                  ? '$free vaga(s) livre(s) de $total'
                  : parking.location,
            ),
            icon: total == 0
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
                : free == 0
                    ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                    : free <= total * 0.3
                        ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
                        : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          );
        })
        .toSet();
  }

  void _mostrarPopupSair() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242f3e),
          title: const Text('Sair', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Tem certeza que deseja sair?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F80ED),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  void _showParkingActionDialog(ParkingModel parking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF616161),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Deseja iniciar o percurso\ncom destino a\n',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 16, 
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: '${parking.name}\n',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: 'ou Reservar uma vaga?',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Fecha o modal de ação atual
                          // AQUI ESTÁ A ALTERAÇÃO: Passando o nome do estacionamento
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RatingScreen(parkingName: parking.name),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8A8A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Ver Perfil',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF2B3D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Iniciar\nPercurso',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500, 
                            fontSize: 15, 
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242f3e),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: const Color(0xFF242f3e),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _mostrarPopupSair,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                  Image.asset('assets/logo.png', height: 32),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(-26.3045, -48.8487),
                      zoom: 14,
                    ),
                    markers: _createMarkers(),
                    style: _darkMapStyle,
                    onMapCreated: (_) {},
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    bottom: _isListVisible ? 0 : -360,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 420,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF969696), Color(0xFF1E1E1E)],
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isListVisible = !_isListVisible),
                            child: Container(
                              color: Colors.transparent,
                              width: double.infinity,
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 12, bottom: 12),
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white70,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'PERTO DE VOCÊ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                          color: Colors.black87,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      if (_loading)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: _loading && _parkings.isEmpty
                                ? const Center(
                                    child: CircularProgressIndicator(color: Colors.white70),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: _parkings.length,
                                    itemBuilder: (context, index) =>
                                        _buildParkingCard(_parkings[index]),

                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingCard(ParkingModel parking) {
    final (free, total) = _effectiveOccupancy(parking);
    final isFull = free == 0 && total > 0;

    final occupancyColor = total == 0
        ? Colors.grey
        : isFull
            ? Colors.redAccent
            : free <= total * 0.3
                ? Colors.orange
                : Colors.green;

    return GestureDetector(
      onTap: () => _showParkingActionDialog(parking),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF8A8A8A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black87, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.location_on, size: 42, color: Colors.black87),
                Positioned(
                  top: 6,
                  child: Icon(Icons.directions_car, size: 16, color: Colors.grey[300]),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parking.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_half,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: occupancyColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        total == 0
                            ? 'Sem dados'
                            : isFull
                                ? 'Lotado'
                                : '$free livre(s) de $total',
                        style: TextStyle(
                          fontSize: 12,
                          color: occupancyColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (parking.distance != null)
              Text(
                parking.distance!,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

