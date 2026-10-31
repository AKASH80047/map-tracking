import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/location_point.dart';

class SosDialog extends StatelessWidget {
  final LocationPoint? currentLocation;

  const SosDialog({
    super.key,
    required this.currentLocation,
  });

  Future<void> _makeEmergencyCall(BuildContext context) async {
    final uri = Uri.parse('tel:${AppConstants.defaultEmergencyNumber}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot initiate phone call on this device/simulator.'),
              backgroundColor: AppColors.sosRed,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calling emergency: $e')),
        );
      }
    }
  }

  Future<void> _shareEmergencyLocation(BuildContext context) async {
    if (currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current GPS position unavailable to share.')),
      );
      return;
    }

    final lat = currentLocation!.position.latitude;
    final lng = currentLocation!.position.longitude;
    final mapLink = 'https://maps.google.com/?q=$lat,$lng';
    final message =
        '🚨 EMERGENCY ALERT: I need assistance! My current live location is:\n'
        'Lat: $lat, Lng: $lng\n'
        'Google Maps: $mapLink';

    await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'EMERGENCY: Live GPS Location',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.all(16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.sosRed.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.sosRed,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Emergency SOS',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Are you in danger or experiencing an accident? Select an action below to get immediate assistance.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (currentLocation != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location, size: 16, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'GPS: ${currentLocation!.position.latitude.toStringAsFixed(5)}, ${currentLocation!.position.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _shareEmergencyLocation(context);
          },
          icon: const Icon(Icons.share_location_rounded, size: 18),
          label: const Text('Share Location'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            side: const BorderSide(color: AppColors.primaryBlue),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            _makeEmergencyCall(context);
          },
          icon: const Icon(Icons.phone_in_talk_rounded, size: 18, color: Colors.white),
          label: const Text('Call 911', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.sosRed,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
