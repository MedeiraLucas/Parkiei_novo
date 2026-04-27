import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/parking_mock.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  
  // NOVA VARIÁVEL: Controla se a lista está aberta ou fechada
  bool _isListVisible = true;

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

  Set<Marker> _createMarkers() {
    return parkingList.map((parking) {
      return Marker(
        markerId: MarkerId(parking.name),
        position: parking.position,
        infoWindow: InfoWindow(
          title: parking.name,
          snippet: parking.distance,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }).toSet();
  }

  void _mostrarPopupSair() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242f3e),
          title: const Text(
            'Sair',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Tem certeza que deseja sair?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white54),
              ),
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

  void _showParkingActionDialog(dynamic parking) {
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
                          Navigator.pop(context);
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
                  Image.asset(
                    'assets/logo.png',
                    height: 32,
                  ),
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
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _mapController!.setMapStyle(_darkMapStyle);
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                  // MUDANÇA: Substituído Positioned por AnimatedPositioned
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300), // Tempo da animação
                    curve: Curves.easeInOut, // Curva de suavização
                    bottom: _isListVisible ? 0 : -360, // Se falso, desce a lista deixando apenas o título visível
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 420,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF969696),
                            Color(0xFF1E1E1E),
                          ],
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        children: [
                          // MUDANÇA: Envolto em GestureDetector para reconhecer o clique
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isListVisible = !_isListVisible; // Inverte o estado ao clicar
                              });
                            },
                            child: Container(
                              color: Colors.transparent, // Necessário para registrar o clique em toda a área
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
                                  const Text(
                                    "PERTO DE VOCÊ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: Colors.black87,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: parkingList.length,
                              itemBuilder: (context, index) {
                                final parking = parkingList[index];
                                return _buildParkingCard(parking);
                              },
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

  Widget _buildParkingCard(dynamic parking) {
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
              color: Colors.black.withOpacity(0.2),
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
                ],
              ),
            ),
            Text(
              parking.distance,
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