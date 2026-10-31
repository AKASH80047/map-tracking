import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;
import '../constants/app_colors.dart';
import '../models/trip_model.dart';
import '../services/trip_tracking_service.dart';
import '../widgets/destination_picker_sheet.dart';
import '../widgets/end_trip_dialog.dart';
import '../widgets/real_map_view.dart';
import '../widgets/sos_dialog.dart';
import '../widgets/trip_bottom_sheet.dart';
import '../widgets/trip_floating_controls.dart';
import '../widgets/trip_summary_dialog.dart';
import '../widgets/trip_top_app_bar.dart';

class TripTrackingScreen extends StatefulWidget {
  const TripTrackingScreen({super.key});

  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  final TripTrackingService _tripService = TripTrackingService();
  MapController? _mapController;

  int _mapStyleIndex = 0; // 0: Carto Voyager, 1: Satellite, 2: OpenStreetMap
  bool _isFollowMode = true;
  bool _isLoading = true;
  bool _hasShownCompletionDialog = false;

  @override
  void initState() {
    super.initState();
    _tripService.addListener(_onTripStatusChanged);
    _initTrip();
  }

  void _onTripStatusChanged() {
    final trip = _tripService.currentTrip;
    if (trip != null &&
        trip.status == TripStatus.completed &&
        !_hasShownCompletionDialog &&
        mounted) {
      _hasShownCompletionDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => TripSummaryDialog(
            trip: trip,
            onStartNewTrip: () {
              _hasShownCompletionDialog = false;
              _initTrip();
            },
          ),
        );
      });
    }
  }

  Future<void> _initTrip() async {
    _hasShownCompletionDialog = false;
    setState(() => _isLoading = true);

    await _tripService.initializeTrip();

    setState(() => _isLoading = false);
  }

  void _onMapCreated(MapController controller) {
    _mapController = controller;
  }

  void _recenterOnVehicle() {
    final trip = _tripService.currentTrip;
    if (_mapController == null || trip == null) return;

    setState(() {
      _isFollowMode = true;
    });

    _mapController!.move(
      ll.LatLng(
        trip.currentLocation.position.latitude,
        trip.currentLocation.position.longitude,
      ),
      15.5,
    );
  }

  void _toggleFollowMode() {
    setState(() {
      _isFollowMode = !_isFollowMode;
    });

    if (_isFollowMode) {
      _recenterOnVehicle();
    }
  }

  void _toggleMapType() {
    setState(() {
      _mapStyleIndex = (_mapStyleIndex + 1) % 3;
    });
  }

  void _zoomIn() {
    if (_mapController == null) return;
    final currentZoom = _mapController!.camera.zoom;
    final target = (currentZoom + 1.0).clamp(11.0, 19.0);
    _mapController!.move(_mapController!.camera.center, target);
  }

  void _zoomOut() {
    if (_mapController == null) return;
    final currentZoom = _mapController!.camera.zoom;
    final target = (currentZoom - 1.0).clamp(11.0, 19.0);
    _mapController!.move(_mapController!.camera.center, target);
  }

  void _fitFullRoute() {
    final trip = _tripService.currentTrip;
    if (_mapController == null || trip == null || trip.routePoints.isEmpty) {
      return;
    }

    setState(() {
      _isFollowMode = false;
    });

    double minLat = trip.routePoints.first.latitude;
    double maxLat = trip.routePoints.first.latitude;
    double minLng = trip.routePoints.first.longitude;
    double maxLng = trip.routePoints.first.longitude;

    for (final point in trip.routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController!.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          ll.LatLng(minLat, minLng),
          ll.LatLng(maxLat, maxLng),
        ),
        padding: const EdgeInsets.only(
          top: 130,
          bottom: 390,
          left: 55,
          right: 55,
        ),
      ),
    );
  }

  Future<void> _openDestinationPicker() async {
    final trip = _tripService.currentTrip;
    if (trip == null) return;

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DestinationPickerSheet(
        currentDestination: trip.destinationLocation,
      ),
    );

    if (selected != null) {
      final newDest = selected['location'] as gmaps.LatLng;
      final name = selected['name'] as String;
      final address = selected['address'] as String;

      await _tripService.changeDestination(
        newDestination: newDest,
        destinationName: name,
        destinationAddress: address,
      );

      _fitFullRoute();
    }
  }

  void _onSosPressed() {
    showDialog(
      context: context,
      builder: (context) => SosDialog(
        currentLocation: _tripService.currentTrip?.currentLocation,
      ),
    );
  }

  Future<void> _onEndTrip() async {
    final current = _tripService.currentTrip;
    if (current != null && current.status == TripStatus.completed) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TripSummaryDialog(
          trip: current,
          onStartNewTrip: () {
            _initTrip();
          },
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const EndTripDialog(),
    );

    if (confirmed == true && mounted) {
      _tripService.endTrip();
      final finalTrip = _tripService.currentTrip;

      if (finalTrip != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => TripSummaryDialog(
            trip: finalTrip,
            onStartNewTrip: () {
              _initTrip();
            },
          ),
        );
      }
    }
  }

  Future<void> _handleBackPressed() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    final trip = _tripService.currentTrip;
    if (trip == null) {
      await SystemNavigator.pop();
      return;
    }

    if (trip.status == TripStatus.inProgress) {
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.pause_circle_outline_rounded, color: Color(0xFF1E6DEB), size: 28),
              SizedBox(width: 10),
              Text(
                'Exit Navigation?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: const Text(
            'Navigation is actively tracking your trip. You can stop tracking and return to the Route Preview, or exit the app.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('resume'),
              child: const Text('Resume', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E6DEB),
                side: const BorderSide(color: Color(0xFF1E6DEB)),
              ),
              onPressed: () => Navigator.of(ctx).pop('preview'),
              child: const Text('Route Preview', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
              onPressed: () => Navigator.of(ctx).pop('exit'),
              child: const Text('Exit App'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      if (action == 'preview') {
        _tripService.resetToPreview();
        _fitFullRoute();
      } else if (action == 'exit') {
        await SystemNavigator.pop();
      }
    } else {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.exit_to_app_rounded, color: Color(0xFF111927), size: 26),
              SizedBox(width: 10),
              Text(
                'Exit App?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to exit the map tracking app?',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF111927)),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Exit'),
            ),
          ],
        ),
      );

      if (shouldExit == true) {
        await SystemNavigator.pop();
      }
    }
  }

  @override
  void dispose() {
    _tripService.removeListener(_onTripStatusChanged);
    _tripService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPressed();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: ListenableBuilder(
          listenable: _tripService,
          builder: (context, _) {
            final trip = _tripService.currentTrip;

            if (_isLoading || trip == null) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryBlue),
                    SizedBox(height: 16),
                    Text(
                      'Initializing live GPS trip...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                // 1. Real Interactive Map with Roads, Parks, Lakes & Streets
                Positioned.fill(
                  child: RealMapView(
                    trip: trip,
                    isFollowMode: _isFollowMode,
                    mapStyleIndex: _mapStyleIndex,
                    onMapCreated: _onMapCreated,
                    onCameraMoveStarted: () {
                      if (_isFollowMode) {
                        setState(() => _isFollowMode = false);
                      }
                    },
                  ),
                ),

                // 2. Draggable Scrollable Bottom Sheet (Middle layer, slides up from bottom)
                TripBottomSheet(
                  trip: trip,
                  onChangeDestination: _openDestinationPicker,
                  onEndTrip: _onEndTrip,
                  onStartTrip: () {
                    _tripService.startTrip();
                    setState(() => _isFollowMode = true);
                  },
                  onVehicleTypeChanged: (type) {
                    _tripService.setVehicleType(type);
                  },
                ),

                // 3. Floating Map Controls (+ / - Zoom, Recenter, Layers, Follow, LIVE)
                // (Positioned cleanly below top app bar, painted above bottom sheet)
                Positioned(
                  right: 16,
                  top: MediaQuery.of(context).padding.top + 76,
                  child: TripFloatingControls(
                    onRecenter: _recenterOnVehicle,
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                    onToggleMapType: _toggleMapType,
                    onToggleFollowMode: _toggleFollowMode,
                    isFollowMode: _isFollowMode,
                    isSimulating: _tripService.isSimulating,
                    onToggleSimulation: () {
                      _tripService.toggleSimulation();
                      if (_tripService.isSimulating) {
                        setState(() => _isFollowMode = true);
                      }
                    },
                  ),
                ),

                // 4. Dark Navy Top App Bar (Topmost layer)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: TripTopAppBar(
                    trip: trip,
                    onBack: _handleBackPressed,
                    onSosPressed: _onSosPressed,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
