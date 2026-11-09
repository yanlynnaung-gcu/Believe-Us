import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/features/anniversary/data/repositories/anniversary_repository_impl.dart';
import 'package:thae_nge_lay/features/anniversary/domain/models/anniversary_milestone.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';

part 'anniversary_notifier.g.dart';

class AnniversaryEngineState {
  final int daysTogether;
  final List<AnniversaryMilestone> milestones;
  final AnniversaryMilestone? nextMilestone;
  final int? daysUntilNextMilestone;
  final bool isLoading;

  const AnniversaryEngineState({
    required this.daysTogether,
    required this.milestones,
    this.nextMilestone,
    this.daysUntilNextMilestone,
    this.isLoading = false,
  });

  AnniversaryEngineState copyWith({
    int? daysTogether,
    List<AnniversaryMilestone>? milestones,
    AnniversaryMilestone? nextMilestone,
    int? daysUntilNextMilestone,
    bool? isLoading,
  }) {
    return AnniversaryEngineState(
      daysTogether: daysTogether ?? this.daysTogether,
      milestones: milestones ?? this.milestones,
      nextMilestone: nextMilestone ?? this.nextMilestone,
      daysUntilNextMilestone:
          daysUntilNextMilestone ?? this.daysUntilNextMilestone,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class AnniversaryNotifier extends _$AnniversaryNotifier {
  @override
  AnniversaryEngineState build() {
    final user = ref.watch(authStateProvider);
    final anniversaryDate = user?.anniversaryDate ??
        DateTime.now().subtract(const Duration(days: 365));

    final now = DateTime.now();
    final daysTogether = now.difference(anniversaryDate).inDays.abs();

    _loadMilestones();

    return AnniversaryEngineState(
      daysTogether: daysTogether < 1 ? 1 : daysTogether,
      milestones: const [],
      isLoading: true,
    );
  }

  Future<void> _loadMilestones() async {
    final user = ref.read(authStateProvider);
    final spaceId = user?.coupleSpaceId ?? 'space_demo';
    final repo = ref.read(anniversaryRepositoryProvider);

    final result = await repo.getMilestones(spaceId);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false),
      (list) {
        final sorted = _computeNextMilestone(list);
        state = state.copyWith(
          milestones: list,
          nextMilestone: sorted.next,
          daysUntilNextMilestone: sorted.days,
          isLoading: false,
        );
      },
    );
  }

  ({AnniversaryMilestone? next, int? days}) _computeNextMilestone(
      List<AnniversaryMilestone> milestones) {
    if (milestones.isEmpty) return (next: null, days: null);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    AnniversaryMilestone? closest;
    int minDays = 999999;

    for (final m in milestones) {
      DateTime target = m.targetDate;
      if (m.isRecurringAnnual) {
        // Project to current year or next year
        target = DateTime(today.year, target.month, target.day);
        if (target.isBefore(today)) {
          target = DateTime(today.year + 1, target.month, target.day);
        }
      }

      final diff = target.difference(today).inDays;
      if (diff >= 0 && diff < minDays) {
        minDays = diff;
        closest = m;
      }
    }

    return (next: closest, days: minDays == 999999 ? null : minDays);
  }

  Future<bool> addMilestone({
    required String title,
    required DateTime targetDate,
    required bool isRecurringAnnual,
    required String iconEmoji,
    String? note,
  }) async {
    final user = ref.read(authStateProvider);
    final spaceId = user?.coupleSpaceId ?? 'space_demo';
    final repo = ref.read(anniversaryRepositoryProvider);

    final result = await repo.addMilestone(
      coupleSpaceId: spaceId,
      title: title,
      targetDate: targetDate,
      isRecurringAnnual: isRecurringAnnual,
      iconEmoji: iconEmoji,
      note: note,
    );

    return result.fold(
      (failure) => false,
      (newMilestone) {
        final updatedList = [...state.milestones, newMilestone];
        final sorted = _computeNextMilestone(updatedList);
        state = state.copyWith(
          milestones: updatedList,
          nextMilestone: sorted.next,
          daysUntilNextMilestone: sorted.days,
        );
        return true;
      },
    );
  }
}
