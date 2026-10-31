import 'dart:math';
import 'package:flutter/material.dart';

class TripFloatingControls extends StatelessWidget {
  final VoidCallback onRecenter;
  final VoidCallback onToggleMapType;
  final VoidCallback onToggleFollowMode;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onToggleSimulation;
  final bool isSimulating;
  final bool isFollowMode;

  const TripFloatingControls({
    super.key,
    required this.onRecenter,
    required this.onToggleMapType,
    required this.onToggleFollowMode,
    this.onZoomIn,
    this.onZoomOut,
    this.onToggleSimulation,
    this.isSimulating = false,
    this.isFollowMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 1. Recenter / Target Button (Circular White)
        _buildCircularButton(
          icon: Icons.my_location,
          tooltip: 'Recenter Location',
          onTap: onRecenter,
        ),

        const SizedBox(height: 10),

        // 2. Map Layers Button (Circular White)
        _buildCircularButton(
          icon: Icons.layers_outlined,
          tooltip: 'Change Map Style',
          onTap: onToggleMapType,
        ),

        const SizedBox(height: 10),

        // 3. Navigation Arrow Button (Circular White with tilted compass needle)
        _buildCircularButton(
          iconWidget: Transform.rotate(
            angle: -pi / 4,
            child: Icon(
              Icons.navigation_rounded,
              color: isFollowMode
                  ? const Color(0xFF1E6DEB)
                  : const Color(0xFF0F172A),
              size: 22,
            ),
          ),
          tooltip: 'Follow Route Mode',
          onTap: onToggleFollowMode,
        ),

        // 4. Google Maps Style Unified Zoom Capsule [ + | - ]
        if (onZoomIn != null && onZoomOut != null) ...[
          const SizedBox(height: 12),
          Container(
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(23),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  offset: const Offset(0, 3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zoom In (+)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(23),
                    ),
                    onTap: onZoomIn,
                    child: const SizedBox(
                      width: 46,
                      height: 42,
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: Color(0xFF0F172A),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),

                // Hairline Divider
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  color: const Color(0xFFE2E8F0),
                ),

                // Zoom Out (-)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(23),
                    ),
                    onTap: onZoomOut,
                    child: const SizedBox(
                      width: 46,
                      height: 42,
                      child: Center(
                        child: Icon(
                          Icons.remove,
                          color: Color(0xFF0F172A),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // 5. Live Simulation Toggle Pill
        if (onToggleSimulation != null) ...[
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggleSimulation,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isSimulating
                      ? const Color(0xFF0F172A)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSimulating
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isSimulating
                            ? const Color(0xFF10B981)
                            : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isSimulating ? 'LIVE' : 'GPS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isSimulating
                            ? Colors.white
                            : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCircularButton({
    IconData? icon,
    Widget? iconWidget,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(23),
          onTap: onTap,
          child: Center(
            child: iconWidget ??
                Icon(
                  icon,
                  color: const Color(0xFF0F172A),
                  size: 22,
                ),
          ),
        ),
      ),
    );
  }
}
