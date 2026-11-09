import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/onboarding/domain/models/onboarding_item.dart';
import 'package:thae_nge_lay/features/onboarding/presentation/controllers/onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      title: 'Two Hearts, One Sacred Space',
      subtitle:
          'Created exclusively for couples in long distance relationships. A private 1-to-1 dreamy sanctuary for your love.',
      highlightWord: 'Sacred Space',
      icon: LucideIcons.heart,
      gradientColors: [Color(0xFFFF5E7E), Color(0xFFFF9A9E)],
    ),
    OnboardingItem(
      title: 'Real-Time Closeness Across Miles',
      subtitle:
          'Mandatory live location sharing, distance gauge, and real-time battery status keep you feeling next to each other always.',
      highlightWord: 'Real-Time Closeness',
      icon: LucideIcons.mapPin,
      gradientColors: [Color(0xFFFF5E7E), Color(0xFFB892FF)],
    ),
    OnboardingItem(
      title: 'Gift Surprises with KBZPay & WavePay',
      subtitle:
          'Send voice memos, celebrate anniversaries, and gift monetary blessings instantly through Myanmar mobile payments.',
      highlightWord: 'Gift Surprises',
      icon: LucideIcons.gift,
      gradientColors: [Color(0xFFD4AF37), Color(0xFFF39C12)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() async {
    final currentIndex = ref.read(onboardingControllerProvider);
    if (currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  void _onSkip() async {
    await ref.read(onboardingControllerProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(onboardingControllerProvider);
    final isLastPage = currentIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: BelieveColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: App Brand & Skip Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          gradient: BelieveColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: BelieveColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.heart,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Thae Thae',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: BelieveColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  if (!isLastPage)
                    TextButton(
                      onPressed: _onSkip,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: BelieveColors.textMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // PageView content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  ref
                      .read(onboardingControllerProvider.notifier)
                      .onPageChanged(index);
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Floating Hero Illustration Container
                        GlassmorphicCard(
                          borderRadius: 120.r,
                          padding: EdgeInsets.all(28.r),
                          child: Container(
                            width: 140.w,
                            height: 140.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: item.gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: item.gradientColors.first
                                      .withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              item.icon,
                              size: 64.r,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 36.h),

                        // Title
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: BelieveColors.textPrimary,
                            height: 1.25,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // Subtitle
                        Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: BelieveColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation & Controls
            Padding(
              padding: EdgeInsets.fromLTRB(28.w, 0, 28.w, 24.h),
              child: Column(
                children: [
                  // Animated Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: currentIndex == index ? 26.w : 7.w,
                        height: 7.h,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? BelieveColors.primary
                              : BelieveColors.border,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Main Button
                  GestureDetector(
                    onTap: _onNext,
                    child: Container(
                      height: 54.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: BelieveColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: BelieveColors.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLastPage ? 'Begin Our Journey ✨' : 'Continue',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            const Icon(
                              LucideIcons.arrowRight,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.lock,
                        size: 13,
                        color: BelieveColors.textMuted,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '1-to-1 Encrypted Connection for Couples Only',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          color: BelieveColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
