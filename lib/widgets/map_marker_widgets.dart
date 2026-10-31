import 'dart:math';
import 'package:flutter/material.dart';
import '../models/vehicle_type.dart';

/// Floating Blue Speech Bubble Callout + 3D Vehicle Marker (Motorcycle Rider or Car)
class RiderWithCalloutWidget extends StatelessWidget {
  final String timeText;
  final String distanceText;
  final double heading;
  final VehicleType vehicleType;
  final bool isCompleted;

  const RiderWithCalloutWidget({
    super.key,
    required this.timeText,
    required this.distanceText,
    this.heading = 45.0,
    this.vehicleType = VehicleType.bike,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool completed = isCompleted || distanceText == '0 m' || timeText == '0 min';
    final badgeColor = completed ? const Color(0xFF059669) : const Color(0xFF0066FF);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Tooltip Callout ("5 min / 1.8 km" or "Arrived! 🎉") matching reference image
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: badgeColor.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                completed ? 'Arrived! 🎉' : timeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  height: 1.15,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                completed ? 'Trip Completed' : distanceText,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),

        // Downward Pointer Triangle
        CustomPaint(
          size: const Size(14, 7),
          painter: _TrianglePainter(color: badgeColor),
        ),

        const SizedBox(height: 3),

        // 2. 3D Vehicle Marker rotated to exact heading
        Transform.rotate(
          angle: heading * (pi / 180.0),
          child: SizedBox(
            width: 58,
            height: 58,
            child: CustomPaint(
              painter: vehicleType == VehicleType.car
                  ? _CarPainter()
                  : _MotorcycleRiderPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3D Motorcycle Rider with Green Jacket, Helmet, and Realistic Wheels
/// Drawn facing NORTH (0° bearing, along -Y axis) so rotation aligns 100% with road heading
class _MotorcycleRiderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Ground Contact Shadow (oriented along travel direction)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, 1),
        width: 22,
        height: 48,
      ),
      shadowPaint,
    );

    // Front Wheel (Top, facing North along -Y)
    final frontWheel = center + const Offset(0, -18);
    final tirePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: frontWheel, width: 6, height: 12),
        const Radius.circular(3),
      ),
      tirePaint,
    );

    // Rear Wheel (Bottom, facing South along +Y)
    final rearWheel = center + const Offset(0, 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: rearWheel, width: 7, height: 13),
        const Radius.circular(3.5),
      ),
      tirePaint,
    );

    // Chassis bar & frame
    final chassisPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawLine(rearWheel, frontWheel, chassisPaint);

    // Chrome Exhaust Pipe on right side
    final exhaustPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center + const Offset(7, 4),
      center + const Offset(7, 18),
      exhaustPaint,
    );

    // Metallic bike body / tank
    final bodyPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + const Offset(0, -5), width: 14, height: 18),
        const Radius.circular(5),
      ),
      bodyPaint,
    );

    // Handlebars (Chrome crossbar)
    final handlePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center + const Offset(-11, -12),
      center + const Offset(11, -12),
      handlePaint,
    );

    // Black Grips
    final gripPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(-11, -12), 2.2, gripPaint);
    canvas.drawCircle(center + const Offset(11, -12), 2.2, gripPaint);

    // Rider Torso (Vibrant Green Jacket #10B981)
    final jacketPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: center + const Offset(0, 3), width: 18, height: 18),
      jacketPaint,
    );

    // Arms leaning forward to handlebars
    final armPaint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center + const Offset(-7, 2), center + const Offset(-10, -11), armPaint);
    canvas.drawLine(center + const Offset(7, 2), center + const Offset(10, -11), armPaint);

    // Helmet (Gloss Black / Dark Charcoal)
    final helmetPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(0, -3), 7.5, helmetPaint);

    // Helmet Visor (Electric blue shine at the front)
    final visorPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: center + const Offset(0, -3), width: 11, height: 11),
      -pi * 0.8,
      pi * 0.6,
      false,
      visorPaint,
    );

    // Headlight (Warm glow at the very front)
    final headlightPaint = Paint()
      ..color = const Color(0xFFFEF08A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(0, -22), 2.5, headlightPaint);

    // Taillight (Red LED at rear)
    final taillightPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(0, 22), 2.5, taillightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3D Modern Car Painter (Used when Car mode is selected)
class _CarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Drop Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + const Offset(0, 4),
          width: 32,
          height: 50,
        ),
        const Radius.circular(10),
      ),
      shadowPaint,
    );

    // Tires
    final tirePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + const Offset(-16, -14), width: 5, height: 10),
        const Radius.circular(2),
      ),
      tirePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + const Offset(16, -14), width: 5, height: 10),
        const Radius.circular(2),
      ),
      tirePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + const Offset(-16, 14), width: 5, height: 10),
        const Radius.circular(2),
      ),
      tirePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + const Offset(16, 14), width: 5, height: 10),
        const Radius.circular(2),
      ),
      tirePaint,
    );

    // Car Body (Navy / Electric Blue)
    final carBodyPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 30, height: 48),
        const Radius.circular(8),
      ),
      carBodyPaint,
    );

    // Windshield (Front glass)
    final glassPaint = Paint()
      ..color = const Color(0xFF93C5FD)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + const Offset(0, -9), width: 22, height: 8),
        const Radius.circular(3),
      ),
      glassPaint,
    );

    // Roof
    final roofPaint = Paint()
      ..color = const Color(0xFF1E40AF)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + const Offset(0, 2), width: 20, height: 14),
        const Radius.circular(4),
      ),
      roofPaint,
    );

    // Rear Windshield
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + const Offset(0, 13), width: 20, height: 6),
        const Radius.circular(2),
      ),
      glassPaint,
    );

    // Headlights (Front white/yellow glow)
    final headlightPaint = Paint()
      ..color = const Color(0xFFFEF08A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(-10, -22), 2.5, headlightPaint);
    canvas.drawCircle(center + const Offset(10, -22), 2.5, headlightPaint);

    // Taillights (Rear red)
    final taillightPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center + const Offset(-10, 22), 2.5, taillightPaint);
    canvas.drawCircle(center + const Offset(10, 22), 2.5, taillightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Start Beacon Marker (Blue circle with outer light-blue halo)
class OriginBeaconWidget extends StatelessWidget {
  const OriginBeaconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.28),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFF1D4ED8),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Destination Pin with "MG Road" title matching reference UI
class DestinationPinWidget extends StatelessWidget {
  final String label;

  const DestinationPinWidget({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Teardrop Red Pin with White Center Cutout
        CustomPaint(
          size: const Size(34, 42),
          painter: _TeardropPinPainter(),
        ),
        const SizedBox(height: 2),
        // Bold label: "MG Road" in a crisp white rounded badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TeardropPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - 2),
        width: 14,
        height: 6,
      ),
      shadowPaint,
    );

    // Red Teardrop Body
    final pinPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.cubicTo(
      size.width / 2, size.height * 0.85,
      0, size.height * 0.50,
      0, size.width / 2,
    );
    path.arcToPoint(
      Offset(size.width, size.width / 2),
      radius: Radius.circular(size.width / 2),
      clockwise: true,
    );
    path.cubicTo(
      size.width, size.height * 0.50,
      size.width / 2, size.height * 0.85,
      size.width / 2, size.height,
    );
    path.close();

    canvas.drawPath(path, pinPaint);

    // Inner White Dot
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.width / 2),
      size.width * 0.22,
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
