import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/controllers/anniversary_notifier.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/widgets/wd_add_milestone_sheet.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/widgets/wd_anniversary_days_banner.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/widgets/wd_milestone_card.dart';

class AnniversaryScreen extends ConsumerStatefulWidget {
  const AnniversaryScreen({super.key});

  @override
  ConsumerState<AnniversaryScreen> createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends ConsumerState<AnniversaryScreen> {
  void _openAddMilestoneSheet() {
    WdAddMilestoneSheet.show(
      context,
      onSave: ({
        required String title,
        required DateTime targetDate,
        required bool isRecurringAnnual,
        required String iconEmoji,
        required String note,
      }) async {
        await ref.read(anniversaryProvider.notifier).addMilestone(
              title: title,
              targetDate: targetDate,
              isRecurringAnnual: isRecurringAnnual,
              iconEmoji: iconEmoji,
              note: note,
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
            WdAnniversaryDaysBanner(daysTogether: state.daysTogether),
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
              ...state.milestones.map((m) => WdMilestoneCard(milestone: m)),
          ],
        ),
      ),
    );
  }
}
