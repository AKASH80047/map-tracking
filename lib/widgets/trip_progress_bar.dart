import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../models/vehicle_type.dart';

class TripProgressBar extends StatelessWidget {
  final TripModel trip;

  const TripProgressBar({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final progress = trip.progressPercentage.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Horizontal Track with Vehicle Rider sitting directly on the line
        LayoutBuilder(
          builder: (context, constraints) {
            final double totalWidth = constraints.maxWidth;
            const double iconWidth = 34.0;
            final double trackWidth = totalWidth - iconWidth;
            final double iconLeft =
                (trackWidth * progress).clamp(0.0, trackWidth);

            return SizedBox(
              height: 36,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // 1. Background light grey track
                  Positioned(
                    left: 2,
                    right: 2,
                    top: 15,
                    child: Container(
                      height: 5.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // 2. Active vibrant green completed track connected to vehicle thumb
                  if (progress > 0.0)
                    Positioned(
                      left: 2,
                      top: 15,
                      child: Container(
                        height: 5.5,
                        width: (iconLeft + (iconWidth / 2)).clamp(0.0, totalWidth),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                  // 3. Moving Vehicle Icon directly at the progress thumb
                  Positioned(
                    left: iconLeft,
                    top: 1,
                    child: Container(
                      width: iconWidth,
                      height: iconWidth,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: const Color(0xFF00C853).withValues(alpha: 0.20),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          trip.status == TripStatus.completed
                              ? Icons.check_circle_rounded
                              : (trip.vehicleType == VehicleType.car
                                  ? Icons.directions_car_rounded
                                  : Icons.two_wheeler_rounded),
                          color: trip.status == TripStatus.completed
                              ? const Color(0xFF00C853)
                              : const Color(0xFF0F172A),
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // 4. Red pin marker at the end of the line (hidden when vehicle thumb reaches destination)
                  if (progress < 0.92)
                    Positioned(
                      right: 0,
                      top: 7,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFEEF0),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFFEF4444),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 6),

        // Under-track row: "Current Location" (Left) and "MG Road" (Right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
            Text(
              trip.destinationName,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
