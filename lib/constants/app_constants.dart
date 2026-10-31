import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppConstants {
  AppConstants._();

  // Pass via --dart-define=MAPS_API_KEY=xxx
  static const String googleMapsApiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: '',
  );

  // Bengaluru coordinates matching reference UI (BTM/Ejipura to MG Road, 1.8 km)
  static const LatLng defaultOrigin = LatLng(12.9460, 77.6180);
  static const LatLng defaultDestination = LatLng(12.9730, 77.6390); // MG Road

  static const String defaultOriginAddress = 'Current Location';
  static const String defaultDestinationName = 'MG Road';
  static const String defaultDestinationAddress = 'MG Road, Bengaluru';

  // Popular preset destinations in Bengaluru
  static const List<Map<String, dynamic>> presetDestinations = [
    {
      'name': 'MG Road',
      'address': 'MG Road, Bengaluru',
      'location': LatLng(12.9756, 77.6066),
      'type': 'City Center',
    },
    {
      'name': 'Indiranagar (100ft Rd)',
      'address': '100 Feet Rd, Indiranagar, Bengaluru',
      'location': LatLng(12.9784, 77.6408),
      'type': 'Hub',
    },
    {
      'name': 'Koramangala (4th Block)',
      'address': '80 Feet Rd, Koramangala 4th Block, Bengaluru',
      'location': LatLng(12.9352, 77.6245),
      'type': 'Commercial',
    },
    {
      'name': 'HSR Layout',
      'address': '27th Main Rd, HSR Layout, Bengaluru',
      'location': LatLng(12.9116, 77.6389),
      'type': 'Neighborhood',
    },
    {
      'name': 'Whitefield (ITPL)',
      'address': 'ITPB Road, Whitefield, Bengaluru',
      'location': LatLng(12.9866, 77.7381),
      'type': 'Tech Park',
    },
  ];

  static const String defaultEmergencyNumber = '911';
}
