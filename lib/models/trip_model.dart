import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'location_point.dart';
import 'vehicle_type.dart';

enum TripStatus {
  ready,
  inProgress,
  paused,
  completed,
  cancelled,
}

class TripModel {
  final String id;
  final String startAddress;
  final LatLng startLocation;
  final String destinationName;
  final String destinationAddress;
  final LatLng destinationLocation;
  final VehicleType vehicleType;
  final DateTime startTime;
  final DateTime? endTime;

  final LocationPoint currentLocation;
  final List<LatLng> routePoints;

  final double totalPlannedDistanceMeters;
  final double distanceTravelledMeters;
  final double distanceRemainingMeters;
  final Duration estimatedRemainingDuration;

  final double currentSpeedKmh;
  final double averageSpeedKmh;
  final double maxSpeedKmh;
  final TripStatus status;
  final bool isSimulated;

  const TripModel({
    required this.id,
    required this.startAddress,
    required this.startLocation,
    required this.destinationName,
    required this.destinationAddress,
    required this.destinationLocation,
    required this.vehicleType,
    required this.startTime,
    this.endTime,
    required this.currentLocation,
    required this.routePoints,
    required this.totalPlannedDistanceMeters,
    required this.distanceTravelledMeters,
    required this.distanceRemainingMeters,
    required this.estimatedRemainingDuration,
    required this.currentSpeedKmh,
    required this.averageSpeedKmh,
    required this.maxSpeedKmh,
    this.status = TripStatus.inProgress,
    this.isSimulated = false,
  });

  double get progressPercentage {
    if (status == TripStatus.completed) return 1.0;
    if (totalPlannedDistanceMeters <= 0) return 0.0;
    if (distanceRemainingMeters <= 0) return 1.0;
    // Derive directly from the remaining distance relative to total planned distance:
    final progress =
        (1.0 - (distanceRemainingMeters / totalPlannedDistanceMeters)).clamp(0.0, 1.0);
    return progress;
  }

  int get progressPercentInt {
    return (progressPercentage * 100).round();
  }

  String get formattedEta {
    final etaTime = DateTime.now().add(estimatedRemainingDuration);
    return DateFormat('h:mm a').format(etaTime);
  }

  String get formattedRemainingTime {
    if (status == TripStatus.completed || distanceRemainingMeters <= 10) {
      return 'Arrived';
    }
    final minutes = (estimatedRemainingDuration.inSeconds / 60).ceil();
    if (minutes <= 0) return 'Arriving';
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remMin = minutes % 60;
    return '${hours}h ${remMin}m';
  }

  String get formattedRemainingDistance {
    if (distanceRemainingMeters < 1000) {
      return '${distanceRemainingMeters.round()} m';
    }
    return '${(distanceRemainingMeters / 1000).toStringAsFixed(1)} km';
  }

  String get formattedTravelledDistance {
    if (distanceTravelledMeters < 1000) {
      return '${distanceTravelledMeters.round()} m';
    }
    return '${(distanceTravelledMeters / 1000).toStringAsFixed(1)} km';
  }

  String get formattedTotalDistance {
    if (totalPlannedDistanceMeters < 1000) {
      return '${totalPlannedDistanceMeters.round()} m';
    }
    return '${(totalPlannedDistanceMeters / 1000).toStringAsFixed(1)} km';
  }

  Duration get tripDuration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  String get formattedTripDuration {
    final d = tripDuration;
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes == 0) return '$seconds sec';
    return '$minutes min $seconds sec';
  }

  TripModel copyWith({
    String? id,
    String? startAddress,
    LatLng? startLocation,
    String? destinationName,
    String? destinationAddress,
    LatLng? destinationLocation,
    VehicleType? vehicleType,
    DateTime? startTime,
    DateTime? endTime,
    LocationPoint? currentLocation,
    List<LatLng>? routePoints,
    double? totalPlannedDistanceMeters,
    double? distanceTravelledMeters,
    double? distanceRemainingMeters,
    Duration? estimatedRemainingDuration,
    double? currentSpeedKmh,
    double? averageSpeedKmh,
    double? maxSpeedKmh,
    TripStatus? status,
    bool? isSimulated,
  }) {
    return TripModel(
      id: id ?? this.id,
      startAddress: startAddress ?? this.startAddress,
      startLocation: startLocation ?? this.startLocation,
      destinationName: destinationName ?? this.destinationName,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      vehicleType: vehicleType ?? this.vehicleType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      currentLocation: currentLocation ?? this.currentLocation,
      routePoints: routePoints ?? this.routePoints,
      totalPlannedDistanceMeters:
          totalPlannedDistanceMeters ?? this.totalPlannedDistanceMeters,
      distanceTravelledMeters:
          distanceTravelledMeters ?? this.distanceTravelledMeters,
      distanceRemainingMeters:
          distanceRemainingMeters ?? this.distanceRemainingMeters,
      estimatedRemainingDuration:
          estimatedRemainingDuration ?? this.estimatedRemainingDuration,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      status: status ?? this.status,
      isSimulated: isSimulated ?? this.isSimulated,
    );
  }
}

