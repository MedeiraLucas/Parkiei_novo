import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingModel {
  final int id;
  final String name;
  final String location;
  final int vacancies;
  final int occupiedSpots;
  final LatLng? position;
  final String? distance;

  const ParkingModel({
    required this.id,
    required this.name,
    required this.location,
    required this.vacancies,
    required this.occupiedSpots,
    this.position,
    this.distance,
  });

  int get freeSpots => vacancies - occupiedSpots;

  factory ParkingModel.fromJson(Map<String, dynamic> json) {
    return ParkingModel(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      vacancies: (json['vacancies'] as num?)?.toInt() ?? 0,
      occupiedSpots: (json['occupiedSpots'] as num?)?.toInt() ?? 0,
    );
  }

  ParkingModel withMapData({required LatLng position, required String distance}) {
    return ParkingModel(
      id: id,
      name: name,
      location: location,
      vacancies: vacancies,
      occupiedSpots: occupiedSpots,
      position: position,
      distance: distance,
    );
  }
}
