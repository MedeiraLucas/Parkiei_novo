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

  // Estilo Dark para o Mapa (JSON)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-26.3045, -48.8487),
          zoom: 14,
        ),
        markers: _createMarkers(),
        onMapCreated: (controller) {
          _mapController = controller;
          // Aplica o tema escuro assim que o mapa é criado
          _mapController!.setMapStyle(_darkMapStyle);
        },
        // Oculta os botões nativos do Google Maps para manter a tela 100% limpa
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
      ),
    );
  }
}