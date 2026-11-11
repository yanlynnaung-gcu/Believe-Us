import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/onboarding/domain/models/onboarding_item.dart';
import 'package:thae_nge_lay/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:thae_nge_lay/features/onboarding/presentation/widgets/wd_onboarding_controls.dart';
import 'package:thae_nge_lay/features/onboarding/presentation/widgets/wd_onboarding_header.dart';
import 'package:thae_nge_lay/features/onboarding/presentation/widgets/wd_onboarding_page_card.dart';

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
            WdOnboardingHeader(isLastPage: isLastPage, onSkip: _onSkip),
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
                  return WdOnboardingPageCard(item: _pages[index]);
                },
              ),
            ),
            WdOnboardingControls(
              currentIndex: currentIndex,
              pageCount: _pages.length,
              isLastPage: isLastPage,
              onNext: _onNext,
            ),
          ],
        ),
      ),
    );
  }
}
