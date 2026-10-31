import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_tracking/models/location_point.dart';
import 'package:map_tracking/models/trip_model.dart';
import 'package:map_tracking/models/vehicle_type.dart';
import 'package:map_tracking/widgets/destination_card.dart';
import 'package:map_tracking/widgets/trip_bottom_sheet.dart';
import 'package:map_tracking/widgets/trip_progress_bar.dart';

void main() {
  final sampleTrip = TripModel(
    id: 'test_trip',
    startAddress: 'Current Location',
    startLocation: const LatLng(12.9602, 77.6015),
    destinationName: 'MG Road',
    destinationAddress: 'MG Road, Bengaluru',
    destinationLocation: const LatLng(12.9756, 77.6066),
    vehicleType: VehicleType.bike,
    startTime: DateTime.now(),
    currentLocation: LocationPoint(
      position: const LatLng(12.9650, 77.6030),
      heading: 45.0,
      speedKmh: 28.0,
    ),
    routePoints: const [
      LatLng(12.9602, 77.6015),
      LatLng(12.9650, 77.6030),
      LatLng(12.9756, 77.6066),
    ],
    totalPlannedDistanceMeters: 1800.0,
    distanceTravelledMeters: 600.0,
    distanceRemainingMeters: 1200.0,
    estimatedRemainingDuration: const Duration(minutes: 5),
    currentSpeedKmh: 28.0,
    averageSpeedKmh: 28.0,
    maxSpeedKmh: 35.0,
  );

  testWidgets('TripProgressBar displays Current Location and destination',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TripProgressBar(trip: sampleTrip),
        ),
      ),
    );

    expect(find.text('Current Location'), findsOneWidget);
    expect(find.text('MG Road'), findsOneWidget);
  });

  testWidgets('DestinationCard renders destination details and responds to change',
      (tester) async {
    bool changeTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DestinationCard(
            name: sampleTrip.destinationName,
            address: sampleTrip.destinationAddress,
            onChangeDestination: () {
              changeTapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('MG Road, Bengaluru'), findsOneWidget);

    await tester.tap(find.text('Change'));
    expect(changeTapped, isTrue);
  });

  testWidgets('TripBottomSheet renders 3 metrics and End Trip button',
      (tester) async {
    bool endTripPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            child: TripBottomSheet(
              trip: sampleTrip,
              initialChildSize: 0.75,
              onChangeDestination: () {},
              onEndTrip: () {
                endTripPressed = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('5 min (1.2 km)'), findsOneWidget);
    expect(find.text('Distance left'), findsOneWidget);
    expect(find.text('Time left'), findsOneWidget);
    expect(find.text('Current speed'), findsOneWidget);
    expect(find.text('End Trip'), findsOneWidget);

    await tester.tap(find.text('End Trip'));
    expect(endTripPressed, isTrue);
  });
}
