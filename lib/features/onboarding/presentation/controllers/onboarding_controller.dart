import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';

part 'onboarding_controller.g.dart';

@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  int build() {
    return 0;
  }

  void onPageChanged(int index) {
    state = index;
  }

  Future<void> completeOnboarding() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setOnboardingCompleted(true);
  }
}
