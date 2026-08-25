import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants.dart';
import '../models/parking_model.dart';

// Dados locais — usados como fallback quando o backend está offline
final _fallbackParkings = [
  ParkingModel(
    id: 1,
    name: 'Estacionamento Principal',
    location: 'Joinville, SC',
    vacancies: 1,
    occupiedSpots: 0,
    position: const LatLng(-26.3045, -48.8487),
    distance: '1,5 Km',
  ),
  ParkingModel(
    id: 2,
    name: 'Estacionamento Central',
    location: 'Joinville, SC',
    vacancies: 0,
    occupiedSpots: 0,
    position: const LatLng(-26.3100, -48.8500),
    distance: '2,0 Km',
  ),
  ParkingModel(
    id: 3,
    name: 'Estacionamento do Tonho',
    location: 'Joinville, SC',
    vacancies: 0,
    occupiedSpots: 0,
    position: const LatLng(-26.3125, -48.8460),
    distance: '2,5 Km',
  ),
  ParkingModel(
    id: 4,
    name: 'Estacionamento JK',
    location: 'Joinville, SC',
    vacancies: 0,
    occupiedSpots: 0,
    position: const LatLng(-26.2990, -48.8520),
    distance: '4,5 Km',
  ),
];

const _mapData = [
  (position: LatLng(-26.3045, -48.8487), distance: '1,5 Km'),
  (position: LatLng(-26.3100, -48.8500), distance: '2,0 Km'),
  (position: LatLng(-26.3125, -48.8460), distance: '2,5 Km'),
  (position: LatLng(-26.2990, -48.8520), distance: '4,5 Km'),
];

class ParkingService {
  static Future<List<ParkingModel>> fetchParkings() async {
    try {
      final response = await http
          .get(Uri.parse('$kApiBaseUrl/parkings'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data.asMap().entries.map((entry) {
            final parking =
                ParkingModel.fromJson(entry.value as Map<String, dynamic>);
            if (entry.key < _mapData.length) {
              final md = _mapData[entry.key];
              return parking.withMapData(
                  position: md.position, distance: md.distance);
            }
            return parking;
          }).toList();
        }
      }
    } catch (_) {
      // backend indisponível — usa dados locais
    }

    return _fallbackParkings;
  }
}
