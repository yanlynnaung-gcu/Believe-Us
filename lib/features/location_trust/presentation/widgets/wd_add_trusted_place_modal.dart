import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Modal bottom sheet to create and configure a new trusted place geofence
void showAddTrustedPlaceModal(
  BuildContext context, {
  required Future<bool> Function({
    required String name,
    required String iconName,
    required double latitude,
    required double longitude,
  }) onSave,
}) {
  final nameCtrl = TextEditingController();
  String selectedIcon = 'home';
  const double lat = 16.8295;
  const double lng = 96.1305;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            padding: EdgeInsets.fromLTRB(
              24.w,
              16.h,
              24.w,
              MediaQuery.of(context).viewInsets.bottom + 28.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: BelieveColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'Add Trusted Place ✨',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: BelieveColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Set a 150m sacred safety zone for instant arrival alerts',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: BelieveColors.textSecondary,
                  ),
                ),
                SizedBox(height: 20.h),

                // Name field
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Place Name',
                    hintText: 'e.g. My Apartment, Study Library, Gym',
                    prefixIcon: const Icon(
                      LucideIcons.mapPin,
                      color: BelieveColors.primary,
                    ),
                    filled: true,
                    fillColor: BelieveColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: BelieveColors.border),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Icon picker
                Text(
                  'Choose Category Icon',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: BelieveColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _IconOption(
                      id: 'home',
                      icon: LucideIcons.home,
                      selectedId: selectedIcon,
                      onTap: () => setModalState(() => selectedIcon = 'home'),
                    ),
                    _IconOption(
                      id: 'briefcase',
                      icon: LucideIcons.briefcase,
                      selectedId: selectedIcon,
                      onTap: () => setModalState(() => selectedIcon = 'briefcase'),
                    ),
                    _IconOption(
                      id: 'coffee',
                      icon: LucideIcons.coffee,
                      selectedId: selectedIcon,
                      onTap: () => setModalState(() => selectedIcon = 'coffee'),
                    ),
                    _IconOption(
                      id: 'heart',
                      icon: LucideIcons.heart,
                      selectedId: selectedIcon,
                      onTap: () => setModalState(() => selectedIcon = 'heart'),
                    ),
                    _IconOption(
                      id: 'school',
                      icon: LucideIcons.graduationCap,
                      selectedId: selectedIcon,
                      onTap: () => setModalState(() => selectedIcon = 'school'),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Save button
                GestureDetector(
                  onTap: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;

                    final success = await onSave(
                      name: name,
                      iconName: selectedIcon,
                      latitude: lat,
                      longitude: lng,
                    );

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Trusted place "$name" saved! ✨'
                              : 'Failed to save place.'),
                          backgroundColor: success
                              ? BelieveColors.success
                              : BelieveColors.error,
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 50.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: BelieveColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: BelieveColors.primary.withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Save Trusted Place 💕',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _IconOption extends StatelessWidget {
  final String id;
  final IconData icon;
  final String selectedId;
  final VoidCallback onTap;

  const _IconOption({
    required this.id,
    required this.icon,
    required this.selectedId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = id == selectedId;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: isSelected ? BelieveColors.primary : BelieveColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? BelieveColors.primary : BelieveColors.border,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : BelieveColors.textPrimary,
        ),
      ),
    );
  }
}
