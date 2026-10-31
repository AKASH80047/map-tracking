import 'package:flutter/material.dart';

enum VehicleType {
  bike,
  car;

  String get displayName {
    switch (this) {
      case VehicleType.bike:
        return 'Motorcycle';
      case VehicleType.car:
        return 'Car';
    }
  }

  IconData get iconData {
    switch (this) {
      case VehicleType.bike:
        return Icons.two_wheeler;
      case VehicleType.car:
        return Icons.directions_car_filled;
    }
  }

  double get simulatedSpeedKmh {
    switch (this) {
      case VehicleType.bike:
        return 42.0;
      case VehicleType.car:
        return 48.0;
    }
  }
}

