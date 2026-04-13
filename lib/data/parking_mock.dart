
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Parking {
  final String name;
  final String distance;
  final LatLng position;

  Parking({
    required this.name,
    required this.distance,
    required this.position,
  });
}

List<Parking> parkingList = [
  Parking(
    name: 'Estacionamento do Tião',
    distance: '1,5 Km',
    position: LatLng(-26.3045, -48.8487),
  ),
  Parking(
    name: 'Estacionamento Central',
    distance: '2,0 Km',
    position: LatLng(-26.3100, -48.8500),
  ),
  Parking(
    name: 'Estacionamento do Tonho',
    distance: '2,5 Km',
    position: LatLng(-26.3125, -48.8460),
  ),
  Parking(
    name: 'Estacionamento JK',
    distance: '4,5 Km',
    position: LatLng(-26.2990, -48.8520),
  ),
];
