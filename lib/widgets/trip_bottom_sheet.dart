import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../models/vehicle_type.dart';
import 'destination_card.dart';
import 'trip_progress_bar.dart';

/// Draggable & Scrollable Bottom Sheet matching the reference image.
/// Supports smooth dragging up and down (collapsed peek, standard trip view, and expanded full overview),
/// as well as tapping the top handle/header to effortlessly expand/collapse.
class TripBottomSheet extends StatefulWidget {
  final TripModel trip;
  final VoidCallback onChangeDestination;
  final VoidCallback onEndTrip;
  final VoidCallback? onStartTrip;
  final ValueChanged<VehicleType>? onVehicleTypeChanged;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  const TripBottomSheet({
    super.key,
    required this.trip,
    required this.onChangeDestination,
    required this.onEndTrip,
    this.onStartTrip,
    this.onVehicleTypeChanged,
    this.initialChildSize = 0.44,
    this.minChildSize = 0.20,
    this.maxChildSize = 0.85,
  });

  @override
  State<TripBottomSheet> createState() => _TripBottomSheetState();
}

class _TripBottomSheetState extends State<TripBottomSheet> {
  late final DraggableScrollableController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _toggleSheetSize() {
    if (!_sheetController.isAttached) return;
    final current = _sheetController.size;
    double target;
    if (current < 0.32) {
      target = widget.initialChildSize;
    } else if (current < 0.65) {
      target = widget.maxChildSize;
    } else {
      target = widget.initialChildSize;
    }

    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_sheetController.isAttached) return;
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight <= 0) return;

    final delta = -details.primaryDelta! / screenHeight;
    final newSize = (_sheetController.size + delta).clamp(
      widget.minChildSize,
      widget.maxChildSize,
    );
    _sheetController.jumpTo(newSize);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!_sheetController.isAttached) return;
    final currentSize = _sheetController.size;
    final velocity = -details.primaryVelocity!;

    double target;
    if (velocity > 350) {
      target = currentSize < 0.40 ? widget.initialChildSize : widget.maxChildSize;
    } else if (velocity < -350) {
      target = currentSize > 0.50 ? widget.initialChildSize : widget.minChildSize;
    } else {
      // Snap to closest position
      final diffMin = (currentSize - widget.minChildSize).abs();
      final diffInit = (currentSize - widget.initialChildSize).abs();
      final diffMax = (currentSize - widget.maxChildSize).abs();
      if (diffMin <= diffInit && diffMin <= diffMax) {
        target = widget.minChildSize;
      } else if (diffInit <= diffMax) {
        target = widget.initialChildSize;
      } else {
        target = widget.maxChildSize;
      }
    }

    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      snap: true,
      snapSizes: [widget.minChildSize, widget.initialChildSize, widget.maxChildSize],
      snapAnimationDuration: const Duration(milliseconds: 250),
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                offset: const Offset(0, -4),
                blurRadius: 20,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              // 1. Top Drag Handle + Tap area
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleSheetSize,
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 2. Title & Subtitle with Drag & Tap support
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleSheetSize,
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.trip.status == TripStatus.completed
                          ? 'Trip Completed! 🎉'
                          : '${widget.trip.formattedRemainingTime} (${widget.trip.formattedRemainingDistance})',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.trip.status == TripStatus.completed
                          ? 'You have arrived at ${widget.trip.destinationName}'
                          : (widget.trip.status == TripStatus.ready
                              ? 'Fastest route • Tap Start Navigation to begin'
                              : 'Estimated arrival at ${widget.trip.formattedEta}'),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: widget.trip.status == TripStatus.completed
                            ? const Color(0xFF059669)
                            : (widget.trip.status == TripStatus.ready
                                ? const Color(0xFF1E6DEB)
                                : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. Horizontal Progress Bar with motorcycle icon & points
              TripProgressBar(trip: widget.trip),

              const SizedBox(height: 16),

              // 4. 3-Metric Row: Distance left, Time left, Current speed
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // Distance left
                    _buildMetricItem(
                      icon: Icons.alt_route_rounded,
                      value: widget.trip.status == TripStatus.completed
                          ? '0 m'
                          : widget.trip.formattedRemainingDistance,
                      label: 'Distance left',
                    ),
                    _buildVerticalDivider(),

                    // Time left
                    _buildMetricItem(
                      icon: Icons.access_time_rounded,
                      value: widget.trip.status == TripStatus.completed
                          ? 'Arrived'
                          : widget.trip.formattedRemainingTime,
                      label: 'Time left',
                    ),
                    _buildVerticalDivider(),

                    // Current speed
                    _buildMetricItem(
                      icon: Icons.speed_rounded,
                      value:
                          '${(widget.trip.status == TripStatus.completed || widget.trip.status == TripStatus.ready) ? 0 : (widget.trip.currentSpeedKmh > 0 ? widget.trip.currentSpeedKmh.round() : 28)} km/h',
                      label: 'Current speed',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 5. Destination Card with Change button
              DestinationCard(
                name: widget.trip.destinationName,
                address: widget.trip.destinationAddress,
                onChangeDestination: widget.onChangeDestination,
              ),

              const SizedBox(height: 16),

              // 6. Action Button: "Start Navigation" (Ready) / "End Trip" (In Progress) / "Trip Completed" (Completed)
              Builder(
                builder: (context) {
                  final isReady = widget.trip.status == TripStatus.ready;
                  final isCompleted = widget.trip.status == TripStatus.completed;

                  final Color btnColor = isReady
                      ? const Color(0xFF1E6DEB) // Royal Navigation Blue
                      : (isCompleted
                          ? const Color(0xFF059669)
                          : const Color(0xFFFF3B30));

                  final VoidCallback? onPressed =
                      isReady ? widget.onStartTrip : widget.onEndTrip;

                  return Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: btnColor.withValues(alpha: 0.38),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isReady)
                            const Icon(Icons.navigation_rounded,
                                color: Colors.white, size: 22)
                          else if (isCompleted)
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 20)
                          else
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          const SizedBox(width: 10),
                          Text(
                            isReady
                                ? 'Start Navigation'
                                : (isCompleted
                                    ? 'Trip Completed • View Summary'
                                    : 'End Trip'),
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 7. Expanded Trip Details (visible when scrolling/dragging sheet up)
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trip Details & Vehicle',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Live Active',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Vehicle Mode Switcher: Bike / Car
              Row(
                children: [
                  Expanded(
                    child: _buildVehicleOption(
                      icon: Icons.two_wheeler,
                      title: 'Motorcycle',
                      subtitle: '28 km/h typical',
                      isSelected: widget.trip.vehicleType == VehicleType.bike,
                      onTap: () => widget.onVehicleTypeChanged?.call(VehicleType.bike),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVehicleOption(
                      icon: Icons.directions_car,
                      title: 'Car',
                      subtitle: '35 km/h typical',
                      isSelected: widget.trip.vehicleType == VehicleType.car,
                      onTap: () => widget.onVehicleTypeChanged?.call(VehicleType.car),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Route Overview Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildRoutePoint(
                      iconColor: const Color(0xFF1D4ED8),
                      title: 'Origin Point',
                      subtitle: widget.trip.startAddress.isNotEmpty
                          ? widget.trip.startAddress
                          : 'Current Location',
                      isStart: true,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 11),
                      height: 16,
                      width: 2,
                      color: const Color(0xFFCBD5E1),
                    ),
                    _buildRoutePoint(
                      iconColor: const Color(0xFFEF4444),
                      title: widget.trip.destinationName,
                      subtitle: widget.trip.destinationAddress,
                      isStart: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Live Status Chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.gps_fixed,
                      color: Color(0xFF2563EB),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Live GPS tracking active • Speed ${widget.trip.currentSpeedKmh.round()} km/h',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: const Color(0xFF0F172A),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 32,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildVehicleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF64748B),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutePoint({
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isStart,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: iconColor, width: 3),
            color: Colors.white,
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
