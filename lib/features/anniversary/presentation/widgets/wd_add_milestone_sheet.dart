import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class WdAddMilestoneSheet extends StatelessWidget {
  final Future<void> Function({
    required String title,
    required DateTime targetDate,
    required bool isRecurringAnnual,
    required String iconEmoji,
    required String note,
  }) onSave;

  const WdAddMilestoneSheet({
    super.key,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function({
      required String title,
      required DateTime targetDate,
      required bool isRecurringAnnual,
      required String iconEmoji,
      required String note,
    }) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WdAddMilestoneSheet(onSave: onSave),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    bool isAnnual = true;
    String selectedEmoji = '❤️';

    final emojis = ['❤️', '💍', '✈️', '💌', '🎂', '🏖️', '🥂', '🏡'];

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          decoration: BoxDecoration(
            color: BelieveColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          padding: EdgeInsets.only(
            top: 20.h,
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: BelieveColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Add Couple Milestone',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: BelieveColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 48.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: emojis.length,
                    itemBuilder: (context, index) {
                      final emoji = emojis[index];
                      final isSelected = emoji == selectedEmoji;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedEmoji = emoji),
                        child: Container(
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? BelieveColors.primarySoft
                                : BelieveColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? BelieveColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: TextStyle(fontSize: 22.sp),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 500 Days of Us, First Trip Together',
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2010),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setSheetState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: BelieveColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: BelieveColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: BelieveColors.primary,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          DateFormat('MMMM d, yyyy').format(selectedDate),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: BelieveColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Recurring Annually',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Repeats every year automatically',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: BelieveColors.textSecondary,
                    ),
                  ),
                  activeThumbColor: BelieveColors.primary,
                  value: isAnnual,
                  onChanged: (val) => setSheetState(() => isAnnual = val),
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;
                    Navigator.of(context).pop();
                    await onSave(
                      title: titleController.text.trim(),
                      targetDate: selectedDate,
                      isRecurringAnnual: isAnnual,
                      iconEmoji: selectedEmoji,
                      note: noteController.text.trim(),
                    );
                  },
                  child: const Text('Save Couple Milestone'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
