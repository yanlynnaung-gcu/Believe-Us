import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/controllers/anniversary_notifier.dart';

class AnniversaryScreen extends ConsumerStatefulWidget {
  const AnniversaryScreen({super.key});

  @override
  ConsumerState<AnniversaryScreen> createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends ConsumerState<AnniversaryScreen> {
  void _openAddMilestoneSheet() {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    bool isAnnual = true;
    String selectedEmoji = '❤️';

    final emojis = ['❤️', '💍', '✈️', '💌', '🎂', '🏖️', '🥂', '🏡'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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

                    // Emoji Selector
                    SizedBox(
                      height: 48.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: emojis.length,
                        itemBuilder: (context, index) {
                          final emoji = emojis[index];
                          final isSelected = emoji == selectedEmoji;
                          return GestureDetector(
                            onTap: () =>
                                setSheetState(() => selectedEmoji = emoji),
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

                    // Title
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 500 Days of Us, First Trip Together',
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Date Picker Trigger
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

                    // Recurring Annual Switch
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
                        await ref
                            .read(anniversaryProvider.notifier)
                            .addMilestone(
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(anniversaryProvider);

    return Scaffold(
      backgroundColor: BelieveColors.background,
      appBar: AppBar(
        title: const Text('Shared Anniversary Timeline'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: BelieveColors.primary),
            onPressed: _openAddMilestoneSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          children: [
            // Days Together Banner
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: BelieveColors.coupleLoveGradient,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Text(
                    '${state.daysTogether}',
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Days of True Devotion',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Every single day bridges the distance.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            Text(
              'Couple Milestones & Memories',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: BelieveColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),

            if (state.milestones.isEmpty)
              const Center(child: Text('No milestones added yet.'))
            else
              ...state.milestones.map((m) {
                final dateStr = DateFormat('MMMM d, yyyy').format(m.targetDate);
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: BelieveColors.surface,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: BelieveColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: BelieveColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            m.iconEmoji,
                            style: TextStyle(fontSize: 20.sp),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.title,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: BelieveColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: BelieveColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (m.isRecurringAnnual)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: BelieveColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'Annual',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: BelieveColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
