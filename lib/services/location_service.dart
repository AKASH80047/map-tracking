import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/location_point.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  LocationPoint? _lastValidPoint;

  /// Check and request location permissions
  Future<LocationPermissionStatus> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    return LocationPermissionStatus.granted;
  }

  /// Get immediate current location
  Future<LocationPoint?> getCurrentLocation() async {
    try {
      final status = await checkAndRequestPermissions();
      if (status != LocationPermissionStatus.granted) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final point = _positionToLocationPoint(position);
      _lastValidPoint = point;
      return point;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Subscribe to real-time location stream
  Stream<LocationPoint> startLocationUpdates({
    int distanceFilterMeters = 3,
  }) {
    final controller = StreamController<LocationPoint>.broadcast();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 3,
    );

    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        final currentPoint = _positionToLocationPoint(position);

        // Filter sudden GPS jitter / false movement
        if (_lastValidPoint != null) {
          final distance = calculateDistanceMeters(
            _lastValidPoint!.position,
            currentPoint.position,
          );

          // Discard negligible movement under 2 meters if speed is low
          if (distance < 2.0 && currentPoint.speedKmh < 1.0) {
            return;
          }

          // Discard unrealistic GPS jumps (> 150 km/h in urban trip)
          final timeDiffSeconds = currentPoint.timestamp
              .difference(_lastValidPoint!.timestamp)
              .inMilliseconds /
              1000.0;
          if (timeDiffSeconds > 0) {
            final calculatedSpeed = (distance / timeDiffSeconds) * 3.6; // km/h
            if (calculatedSpeed > 200) {
              debugPrint('Rejected GPS glitch speed: $calculatedSpeed km/h');
              return;
            }
          }

          // Calculate heading from consecutive coordinates if hardware heading is unavailable
          double heading = currentPoint.heading;
          if (heading <= 0 && distance >= 3.0) {
            heading = calculateBearing(
              _lastValidPoint!.position,
              currentPoint.position,
            );
          }

          final smoothedPoint = currentPoint.copyWith(heading: heading);
          _lastValidPoint = smoothedPoint;
          controller.add(smoothedPoint);
        } else {
          _lastValidPoint = currentPoint;
          controller.add(currentPoint);
        }
      },
      onError: (error) {
        debugPrint('Location stream error: $error');
        controller.addError(error);
      },
    );

    return controller.stream;
  }

  /// Stop listening to position updates
  void stopLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _lastValidPoint = null;
  }

  /// Convert Geolocator Position to our LocationPoint model
  LocationPoint _positionToLocationPoint(Position pos) {
    // Speed is in m/s, convert to km/h
    final speedKmh = pos.speed > 0 ? (pos.speed * 3.6) : 0.0;
    return LocationPoint(
      position: LatLng(pos.latitude, pos.longitude),
      heading: pos.heading >= 0 ? pos.heading : 0.0,
      speedKmh: speedKmh,
      accuracy: pos.accuracy,
      timestamp: pos.timestamp,
    );
  }

  /// Calculate distance between two coordinates in meters
  static double calculateDistanceMeters(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Calculate bearing (direction in degrees 0-360) from coordinate A to B
  static double calculateBearing(LatLng start, LatLng end) {
    final double startLat = _degreesToRadians(start.latitude);
    final double startLng = _degreesToRadians(start.longitude);
    final double endLat = _degreesToRadians(end.latitude);
    final double endLng = _degreesToRadians(end.longitude);

    final double dLng = endLng - startLng;

    final double y = sin(dLng) * cos(endLat);
    final double x = cos(startLat) * sin(endLat) -
        sin(startLat) * cos(endLat) * cos(dLng);

    final double bearingRadians = atan2(y, x);
    final double bearingDegrees = _radiansToDegrees(bearingRadians);

    return (bearingDegrees + 360) % 360;
  }

  static double _degreesToRadians(double degrees) => degrees * (pi / 180.0);
  static double _radiansToDegrees(double radians) => radians * (180.0 / pi);
}

