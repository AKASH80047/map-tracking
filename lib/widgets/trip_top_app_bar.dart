import 'package:flutter/material.dart';
import '../models/trip_model.dart';

class TripTopAppBar extends StatelessWidget {
  final TripModel? trip;
  final VoidCallback onBack;
  final VoidCallback onSosPressed;

  const TripTopAppBar({
    super.key,
    required this.trip,
    required this.onBack,
    required this.onSosPressed,
  });

  @override
  Widget build(BuildContext context) {
    final status = trip?.status ?? TripStatus.ready;
    final isCompleted = status == TripStatus.completed;
    final isInProgress = status == TripStatus.inProgress;

    // Subtitle string
    String subtitle;
    Color statusDotColor;
    if (isCompleted) {
      subtitle = 'Arrived at ${trip?.destinationName ?? "Destination"}';
      statusDotColor = const Color(0xFF10B981); // Emerald
    } else if (isInProgress) {
      subtitle =
          'To ${trip?.destinationName ?? "MG Road"} • ${trip?.formattedRemainingDistance ?? "1.8 km"} (${trip?.formattedRemainingTime ?? "5 min"})';
      statusDotColor = const Color(0xFF10B981); // Live Emerald
    } else {
      subtitle =
          'To ${trip?.destinationName ?? "MG Road"} • 1.8 km (5 min)';
      statusDotColor = const Color(0xFF3B82F6); // Blue preview
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A), // Slate 900
            Color(0xFF141F36), // Deep Navy Slate
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          child: Row(
            children: [
              // 1. Sleek Modern Back Button
              Material(
                color: const Color(0xFF1E293B).withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 2. Title & Live Status Subtitle
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCompleted
                          ? 'Trip Completed! 🎉'
                          : (isInProgress ? 'Trip in Progress' : 'Route Preview'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        // Live pulsing indicator dot
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusDotColor,
                            boxShadow: [
                              BoxShadow(
                                color: statusDotColor.withValues(alpha: 0.6),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8), // Slate 400
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // 3. Ultra-refined SOS Emergency Pill Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF3B30),
                      Color(0xFFE11D48),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: onSosPressed,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emergency_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
