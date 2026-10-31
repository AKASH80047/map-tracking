import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class DestinationPickerSheet extends StatefulWidget {
  final LatLng currentDestination;

  const DestinationPickerSheet({
    super.key,
    required this.currentDestination,
  });

  @override
  State<DestinationPickerSheet> createState() => _DestinationPickerSheetState();
}

class _DestinationPickerSheetState extends State<DestinationPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDestinations = [];

  @override
  void initState() {
    super.initState();
    _filteredDestinations = List.from(AppConstants.presetDestinations);
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredDestinations = List.from(AppConstants.presetDestinations);
      } else {
        final q = query.toLowerCase();
        _filteredDestinations = AppConstants.presetDestinations.where((item) {
          final name = (item['name'] as String).toLowerCase();
          final addr = (item['address'] as String).toLowerCase();
          return name.contains(q) || addr.contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.pillGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Change Destination',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Search or pick from popular locations',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Search Field
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search landmark, mall, or address...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Destinations List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _filteredDestinations.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _filteredDestinations[index];
                final LatLng loc = item['location'] as LatLng;
                final bool isSelected =
                    (loc.latitude == widget.currentDestination.latitude &&
                        loc.longitude == widget.currentDestination.longitude);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue.withValues(alpha: 0.15)
                          : AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.place_rounded,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item['name'] as String,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    item['address'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryBlue,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
  }
}
