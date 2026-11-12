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

  Future<void> _editAnniversaryDate() async {
    final state = ref.read(anniversaryProvider);
    final initialDate = state.officialStartDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(DateTime.now()) ? DateTime.now() : initialDate,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      helpText: 'Select Couple Official Start Date',
    );

    if (picked != null) {
      final success = await ref
          .read(anniversaryProvider.notifier)
          .updateAnniversaryDate(picked);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Official anniversary date synced with partner! ❤️'
                  : 'Failed to update anniversary date.',
            ),
          ),
        );
      }
    }
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
            icon: const Icon(Icons.edit_calendar_rounded, color: BelieveColors.primary),
            tooltip: 'Edit Start Date',
            onPressed: _editAnniversaryDate,
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: BelieveColors.primary),
            onPressed: _openAddMilestoneSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WdAnniversaryDaysBanner(
                      daysTogether: state.daysTogether,
                      onTapEditDate: _editAnniversaryDate,
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('No milestones added yet.')),
                      ),
                  ],
                ),
              ),
            ),
            if (state.milestones.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverList.builder(
                  itemCount: state.milestones.length,
                  itemBuilder: (context, index) {
                    final milestone = state.milestones[index];
                    return RepaintBoundary(
                      child: WdMilestoneCard(milestone: milestone),
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }
}
