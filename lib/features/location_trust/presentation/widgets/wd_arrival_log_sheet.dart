import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/partner_location_arrival_model.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/location_detail_controller.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/widgets/wd_arrival_timeline_tab.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/widgets/wd_live_status_card.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/widgets/wd_trusted_places_tab.dart';

/// Draggable bottom sheet containing live status, arrival history, and trusted places
class WdArrivalLogSheet extends StatelessWidget {
  final DraggableScrollableController sheetController;
  final TabController tabController;
  final LocationDetailState state;
  final VoidCallback onToggleSheet;
  final VoidCallback onSendNudge;
  final void Function(PartnerLocationArrivalModel log) onLogSelected;
  final VoidCallback onAddPlace;
  final Future<void> Function() onRefresh;

  const WdArrivalLogSheet({
    super.key,
    required this.sheetController,
    required this.tabController,
    required this.state,
    required this.onToggleSheet,
    required this.onSendNudge,
    required this.onLogSelected,
    required this.onAddPlace,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.45,
      minChildSize: 0.08,
      maxChildSize: 0.88,
      snap: true,
      snapSizes: const [0.08, 0.45, 0.88],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            border: Border.all(color: BelieveColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Sheet Handle
              GestureDetector(
                onTap: onToggleSheet,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 20.w,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 44.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: BelieveColors.border,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.history,
                                  size: 15,
                                  color: BelieveColors.primary,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Today\'s Arrival Log & Places',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: BelieveColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: BelieveColors.primarySoft,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '${state.todayArrivalLogs.length} events',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: BelieveColors.burgundy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Live Status Card
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 4.h,
                ),
                child: WdLiveStatusCard(
                  state: state,
                  onSendNudge: onSendNudge,
                ),
              ),

              SizedBox(height: 6.h),

              // Tab Bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: BelieveColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: TabBar(
                  controller: tabController,
                  indicator: BoxDecoration(
                    gradient: BelieveColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: BelieveColors.textSecondary,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(text: "Today's Arrival Log"),
                    Tab(text: "Trusted Places (150m)"),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    WdArrivalTimelineTab(
                      state: state,
                      scrollController: scrollController,
                      onRefresh: onRefresh,
                      onLogSelected: onLogSelected,
                    ),
                    WdTrustedPlacesTab(
                      state: state,
                      scrollController: scrollController,
                      onAddPlace: onAddPlace,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
