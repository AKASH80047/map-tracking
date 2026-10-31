import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/vehicle_type.dart';

class MarkerGenerator {
  MarkerGenerator._();

  /// Creates the exact motorcycle rider marker with the floating blue ETA/distance callout bubble
  static Future<BitmapDescriptor> createVehicleWithCalloutMarker({
    required VehicleType vehicleType,
    required String timeText,
    required String distanceText,
    double width = 160.0,
    double height = 210.0,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // 1. Draw Floating Blue Speech Bubble Callout
    final double calloutW = 108.0;
    final double calloutH = 58.0;
    final double calloutX = (width - calloutW) / 2;
    const double calloutY = 8.0;

    // Callout Shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(calloutX, calloutY + 2, calloutW, calloutH),
        const Radius.circular(10),
      ),
      shadowPaint,
    );

    // Callout Background (Vibrant Blue #1E6DEB)
    final Paint bubblePaint = Paint()
      ..color = const Color(0xFF1E6DEB)
      ..style = PaintingStyle.fill;
    final RRect bubbleRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(calloutX, calloutY, calloutW, calloutH),
      const Radius.circular(10),
    );
    canvas.drawRRect(bubbleRRect, bubblePaint);

    // Downward Pointer Arrow
    final Path pointerPath = Path();
    final double arrowCenterX = width / 2;
    final double arrowBaseY = calloutY + calloutH;
    pointerPath.moveTo(arrowCenterX - 8, arrowBaseY);
    pointerPath.lineTo(arrowCenterX + 8, arrowBaseY);
    pointerPath.lineTo(arrowCenterX, arrowBaseY + 9);
    pointerPath.close();
    canvas.drawPath(pointerPath, bubblePaint);

    // Callout Text: Line 1 = "5 min"
    final TextPainter timePainter = TextPainter(
      text: TextSpan(
        text: timeText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: calloutW);
    timePainter.paint(
      canvas,
      Offset(arrowCenterX - (timePainter.width / 2), calloutY + 8),
    );

    // Callout Text: Line 2 = "1.8 km"
    final TextPainter distPainter = TextPainter(
      text: TextSpan(
        text: distanceText,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: calloutW);
    distPainter.paint(
      canvas,
      Offset(arrowCenterX - (distPainter.width / 2), calloutY + 30),
    );

    // 2. Draw Motorcycle & Rider directly below the callout
    final double riderCenterY = calloutY + calloutH + 46;
    final Offset riderCenter = Offset(width / 2, riderCenterY);

    // Ground contact shadow
    final Paint groundShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(
        center: riderCenter + const Offset(0, 24),
        width: 60,
        height: 18,
      ),
      groundShadow,
    );

    if (vehicleType == VehicleType.bike) {
      // --- Motorcycle Wheels ---
      final Paint tirePaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;
      final Paint rimPaint = Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      // Front wheel
      canvas.drawCircle(riderCenter + const Offset(18, 16), 11, tirePaint);
      canvas.drawCircle(riderCenter + const Offset(18, 16), 6, rimPaint);

      // Rear wheel
      canvas.drawCircle(riderCenter + const Offset(-18, 16), 11, tirePaint);
      canvas.drawCircle(riderCenter + const Offset(-18, 16), 6, rimPaint);

      // Chassis & Exhaust
      final Paint chassisPaint = Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawLine(
        riderCenter + const Offset(-18, 16),
        riderCenter + const Offset(0, 10),
        chassisPaint,
      );
      canvas.drawLine(
        riderCenter + const Offset(0, 10),
        riderCenter + const Offset(18, 16),
        chassisPaint,
      );

      // Bike Body (Dark metallic)
      final Paint bodyPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: riderCenter + const Offset(2, 6),
            width: 32,
            height: 12,
          ),
          const Radius.circular(4),
        ),
        bodyPaint,
      );

      // Rider Torso (Vibrant Green Jacket #10B981)
      final Paint jacketPaint = Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: riderCenter + const Offset(-2, -4),
          width: 20,
          height: 24,
        ),
        jacketPaint,
      );

      // Rider Arms (leaning forward to handlebars)
      final Paint armPaint = Paint()
        ..color = const Color(0xFF059669)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        riderCenter + const Offset(0, -6),
        riderCenter + const Offset(14, 4),
        armPaint,
      );

      // Helmet (Gloss Black / Dark Charcoal)
      final Paint helmetPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(riderCenter + const Offset(-1, -19), 9, helmetPaint);

      // Helmet Visor (Teal accent)
      final Paint visorPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        riderCenter + const Offset(4, -19),
        riderCenter + const Offset(8, -17),
        visorPaint,
      );
    } else {
      // Car Icon / representation
      final Paint carPaint = Paint()
        ..color = const Color(0xFF2563EB)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: riderCenter, width: 44, height: 28),
          const Radius.circular(8),
        ),
        carPaint,
      );
      final Paint windowPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: riderCenter + const Offset(0, -2),
            width: 34,
            height: 14,
          ),
          const Radius.circular(4),
        ),
        windowPaint,
      );
    }

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image =
        await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  /// Creates the circular blue origin beacon with light blue translucent halo
  static Future<BitmapDescriptor> createOriginBeaconMarker({
    double size = 70.0,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Offset center = Offset(size / 2, size / 2);

    // 1. Light-blue outer halo (translucent)
    final Paint haloPaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.45, haloPaint);

    // 2. White outline ring
    final Paint whiteRingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.28, whiteRingPaint);

    // 3. Vibrant blue solid center core
    final Paint corePaint = Paint()
      ..color = const Color(0xFF1D4ED8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size * 0.20, corePaint);

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  /// Creates the red destination teardrop pin with "MG Road" label
  static Future<BitmapDescriptor> createDestinationPinWithLabel({
    String label = 'MG Road',
    double width = 120.0,
    double height = 90.0,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Offset pinCenter = Offset(width / 2, 28);
    const double radius = 18.0;

    // Pin shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width / 2, 58),
        width: 18,
        height: 8,
      ),
      shadowPaint,
    );

    // Pin body (Red #EF4444)
    final Path pinPath = Path();
    pinPath.moveTo(width / 2, 56);
    pinPath.quadraticBezierTo(
      width / 2 - radius,
      38,
      width / 2 - radius,
      pinCenter.dy,
    );
    pinPath.arcTo(
      Rect.fromCircle(center: pinCenter, radius: radius),
      3.14159,
      3.14159,
      false,
    );
    pinPath.quadraticBezierTo(
      width / 2 + radius,
      38,
      width / 2,
      56,
    );
    pinPath.close();

    final Paint pinPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawPath(pinPath, pinPaint);

    // White inner dot
    final Paint whiteDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pinCenter, 7, whiteDot);

    // Label below pin: "MG Road" (Bold black text with subtle white halo)
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 13,
          fontWeight: FontWeight.w800,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: width);

    // Text background pill for readability over map
    final double textW = textPainter.width + 12;
    final double textH = textPainter.height + 4;
    final double textX = (width - textW) / 2;
    const double textY = 62.0;

    final Paint labelBg = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(textX, textY, textW, textH),
        const Radius.circular(6),
      ),
      labelBg,
    );

    textPainter.paint(
      canvas,
      Offset((width - textPainter.width) / 2, textY + 2),
    );

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image =
        await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }
}
