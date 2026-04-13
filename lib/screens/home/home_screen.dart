
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/parking_mock.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Set<Marker> _createMarkers() {
    return parkingList.map((parking) {
      return Marker(
        markerId: MarkerId(parking.name),
        position: parking.position,
        infoWindow: InfoWindow(
          title: parking.name,
          snippet: parking.distance,
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            Container(
              height: 300,
              margin: const EdgeInsets.all(10),

              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-26.3045, -48.8487),
                  zoom: 14,
                ),
                markers: _createMarkers(),
              ),
            ),

            const Text(
              'PERTO DE VOCÊ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: parkingList.length,
                itemBuilder: (context, index) {

                  final parking = parkingList[index];

                  return ListTile(
                    title: Text(parking.name),
                    trailing: Text(parking.distance),
                  );

                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
