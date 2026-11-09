import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

part 'media_picker_service.g.dart';

enum CropType {
  circleAvatar,
  coverPhoto,
}

class MediaPickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickAndCropImage({
    required BuildContext context,
    required CropType cropType,
    String title = 'Capture Our Memory ✨',
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _MemoryPickerSheet(title: title),
    );

    if (source == null) return null;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 1440,
    );

    if (picked == null) return null;

    return await _cropImage(
      sourcePath: picked.path,
      cropType: cropType,
    );
  }

  Future<File?> _cropImage({
    required String sourcePath,
    required CropType cropType,
  }) async {
    final isCircle = cropType == CropType.circleAvatar;

    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Memory ✨',
            toolbarColor: BelieveColors.primary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: BelieveColors.primary,
            cropStyle: isCircle ? CropStyle.circle : CropStyle.rectangle,
            initAspectRatio: isCircle
                ? CropAspectRatioPreset.square
                : CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: true,
            aspectRatioPresets: isCircle
                ? [CropAspectRatioPreset.square]
                : [CropAspectRatioPreset.ratio16x9, CropAspectRatioPreset.ratio4x3],
          ),
          IOSUiSettings(
            title: 'Crop Memory ✨',
            cropStyle: isCircle ? CropStyle.circle : CropStyle.rectangle,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (cropped != null) {
        return File(cropped.path);
      }
      return File(sourcePath);
    } catch (_) {
      // Fallback to uncropped file if cropper is cancelled or unhandled
      return File(sourcePath);
    }
  }
}

class _MemoryPickerSheet extends StatelessWidget {
  final String title;

  const _MemoryPickerSheet({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BelieveColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 36.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: BelieveColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 18.h),

          // Title
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Keep your sacred connection vibrant and intimate',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: BelieveColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),

          // Option 1: Take Photo (Camera)
          GlassmorphicCard(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            margin: EdgeInsets.only(bottom: 12.h),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: BelieveColors.primaryGradient,
                  ),
                  child: const Icon(
                    LucideIcons.camera,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Take a Photo',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Capture this exact moment with your camera',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        color: BelieveColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Option 2: Choose from Gallery (Camera Roll)
          GlassmorphicCard(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: BelieveColors.romanticSunsetGradient,
                  ),
                  child: const Icon(
                    LucideIcons.image,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose from Gallery',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Pick from your saved romantic memories',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        color: BelieveColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Riverpod(keepAlive: true)
MediaPickerService mediaPickerService(Ref ref) {
  return MediaPickerService();
}
