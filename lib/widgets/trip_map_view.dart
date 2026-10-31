import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/trip_model.dart';
import '../utils/marker_generator.dart';

class TripMapView extends StatefulWidget {
  final TripModel trip;
  final MapType mapType;
  final bool isFollowMode;
  final ValueChanged<GoogleMapController> onMapCreated;
  final VoidCallback? onCameraMoveStarted;

  const TripMapView({
    super.key,
    required this.trip,
    required this.mapType,
    required this.isFollowMode,
    required this.onMapCreated,
    this.onCameraMoveStarted,
  });

  @override
  State<TripMapView> createState() => _TripMapViewState();
}

class _TripMapViewState extends State<TripMapView>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;

  BitmapDescriptor? _vehicleCalloutMarker;
  BitmapDescriptor? _destinationMarker;
  BitmapDescriptor? _originBeaconMarker;

  late AnimationController _animController;
  LatLng _prevPosition = const LatLng(0, 0);
  LatLng _targetPosition = const LatLng(0, 0);
  double _prevHeading = 0.0;
  double _targetHeading = 0.0;

  String _lastCalloutTime = '';
  String _lastCalloutDist = '';

  @override
  void initState() {
    super.initState();
    _targetPosition = widget.trip.currentLocation.position;
    _prevPosition = _targetPosition;
    _targetHeading = widget.trip.currentLocation.heading;
    _prevHeading = _targetHeading;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _loadCustomMarkers();
  }

  Future<void> _loadCustomMarkers() async {
    try {
      final origin = await MarkerGenerator.createOriginBeaconMarker();
      final dest = await MarkerGenerator.createDestinationPinWithLabel(
        label: widget.trip.destinationName,
      );

      final timeText = widget.trip.formattedRemainingTime;
      final distText = widget.trip.formattedRemainingDistance;
      _lastCalloutTime = timeText;
      _lastCalloutDist = distText;

      final vehicle = await MarkerGenerator.createVehicleWithCalloutMarker(
        vehicleType: widget.trip.vehicleType,
        timeText: timeText,
        distanceText: distText,
      );

      if (mounted) {
        setState(() {
          _originBeaconMarker = origin;
          _destinationMarker = dest;
          _vehicleCalloutMarker = vehicle;
        });
      }
    } catch (e) {
      debugPrint('Error loading custom markers: $e');
    }
  }

  @override
  void didUpdateWidget(TripMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentPos = widget.trip.currentLocation.position;
    final currentHeading = widget.trip.currentLocation.heading;

    // Refresh callout if ETA or distance changed
    final timeText = widget.trip.formattedRemainingTime;
    final distText = widget.trip.formattedRemainingDistance;
    if (timeText != _lastCalloutTime || distText != _lastCalloutDist) {
      _lastCalloutTime = timeText;
      _lastCalloutDist = distText;
      MarkerGenerator.createVehicleWithCalloutMarker(
        vehicleType: widget.trip.vehicleType,
        timeText: timeText,
        distanceText: distText,
      ).then((marker) {
        if (mounted) {
          setState(() {
            _vehicleCalloutMarker = marker;
          });
        }
      });
    }

    if (currentPos != _targetPosition) {
      _prevPosition = _interpolatedPosition;
      _targetPosition = currentPos;

      _prevHeading = _interpolatedHeading;
      _targetHeading = currentHeading;

      _animController.forward(from: 0.0);

      if (widget.isFollowMode && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentPos,
              zoom: 15.5,
              tilt: 0.0,
            ),
          ),
        );
      }
    }
  }

  LatLng get _interpolatedPosition {
    final t = _animController.value;
    final lat = _prevPosition.latitude +
        (_targetPosition.latitude - _prevPosition.latitude) * t;
    final lng = _prevPosition.longitude +
        (_targetPosition.longitude - _prevPosition.longitude) * t;
    return LatLng(lat, lng);
  }

  double get _interpolatedHeading {
    final t = _animController.value;
    double diff = (_targetHeading - _prevHeading) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return (_prevHeading + diff * t) % 360;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final LatLng currentVehiclePos = _interpolatedPosition;

        final Set<Marker> markers = {};

        // 1. Origin Beacon Marker (Blue circle with outer light-blue halo)
        markers.add(
          Marker(
            markerId: const MarkerId('origin_marker'),
            position: widget.trip.startLocation,
            icon: _originBeaconMarker ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
            anchor: const Offset(0.5, 0.5),
          ),
        );

        // 2. Destination Pin (Red teardrop pin + "MG Road" label)
        markers.add(
          Marker(
            markerId: const MarkerId('destination_marker'),
            position: widget.trip.destinationLocation,
            icon: _destinationMarker ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            anchor: const Offset(0.5, 0.65),
          ),
        );

        // 3. Vehicle Marker with Floating Blue Speech Bubble Callout
        markers.add(
          Marker(
            markerId: const MarkerId('vehicle_marker'),
            position: currentVehiclePos,
            icon: _vehicleCalloutMarker ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            anchor: const Offset(0.5, 0.72),
            zIndexInt: 10,
          ),
        );

        // Route Polylines: Blue navigation route with casing
        final Set<Polyline> polylines = {};

        if (widget.trip.routePoints.isNotEmpty) {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('route_glow'),
              points: widget.trip.routePoints,
              color: const Color(0x662563EB),
              width: 9,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );

          polylines.add(
            Polyline(
              polylineId: const PolylineId('route_main'),
              points: widget.trip.routePoints,
              color: const Color(0xFF1E6DEB),
              width: 5,
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
            ),
          );
        }

        final LatLng centerTarget = widget.trip.routePoints.isNotEmpty
            ? widget.trip.routePoints[widget.trip.routePoints.length ~/ 2]
            : widget.trip.startLocation;

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: centerTarget,
            zoom: 14.5,
            tilt: 0.0,
          ),
          mapType: widget.mapType,
          markers: markers,
          polylines: polylines,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          trafficEnabled: false,
          mapToolbarEnabled: false,
          padding: const EdgeInsets.only(
            top: 75,
            bottom: 300,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            widget.onMapCreated(controller);
          },
          onCameraMoveStarted: () {
            widget.onCameraMoveStarted?.call();
          },
        );
      },
    );
  }
}
