import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/core/utils/anniversary_date_utils.dart';
import 'package:thae_nge_lay/features/anniversary/data/repositories/anniversary_repository_impl.dart';
import 'package:thae_nge_lay/features/anniversary/domain/models/anniversary_milestone.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/pairing/data/repositories/pairing_repository_impl.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_summary.dart';

part 'anniversary_notifier.g.dart';

class AnniversaryEngineState {
  final int daysTogether;
  final DateTime? officialStartDate;
  final DateTime? serverTime;
  final List<AnniversaryMilestone> milestones;
  final AnniversaryMilestone? nextMilestone;
  final int? daysUntilNextMilestone;
  final bool isLoading;

  const AnniversaryEngineState({
    required this.daysTogether,
    this.officialStartDate,
    this.serverTime,
    required this.milestones,
    this.nextMilestone,
    this.daysUntilNextMilestone,
    this.isLoading = false,
  });

  AnniversaryEngineState copyWith({
    int? daysTogether,
    DateTime? officialStartDate,
    DateTime? serverTime,
    List<AnniversaryMilestone>? milestones,
    AnniversaryMilestone? nextMilestone,
    int? daysUntilNextMilestone,
    bool? isLoading,
  }) {
    return AnniversaryEngineState(
      daysTogether: daysTogether ?? this.daysTogether,
      officialStartDate: officialStartDate ?? this.officialStartDate,
      serverTime: serverTime ?? this.serverTime,
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
  StreamSubscription? _wsAnniversarySub;
  StreamSubscription? _wsMilestoneAddedSub;
  StreamSubscription? _wsMilestoneDeletedSub;
  StreamSubscription? _wsPairedSub;

  @override
  AnniversaryEngineState build() {
    ref.onDispose(() {
      _wsAnniversarySub?.cancel();
      _wsMilestoneAddedSub?.cancel();
      _wsMilestoneDeletedSub?.cancel();
      _wsPairedSub?.cancel();
    });

    final storage = ref.watch(localStorageServiceProvider);
    final user = ref.watch(authStateProvider);

    // Prefer cached official anniversary date, then user profile
    final officialStart = storage.anniversaryDate ?? user?.anniversaryDate;

    // Calculate days together in UTC without timezone skew
    final initialDays = officialStart != null
        ? AnniversaryDateUtils.calculateDaysTogether(officialStart)
        : (storage.daysTogether ?? 1);

    _setupWebSocketListeners();
    Future.microtask(() => syncAnniversaryFromBackend());

    return AnniversaryEngineState(
      daysTogether: initialDays < 1 ? 1 : initialDays,
      officialStartDate: officialStart,
      milestones: const [],
      isLoading: true,
    );
  }

  void _setupWebSocketListeners() {
    _wsAnniversarySub?.cancel();
    _wsMilestoneAddedSub?.cancel();
    _wsMilestoneDeletedSub?.cancel();
    _wsPairedSub?.cancel();

    final ws = ref.read(webSocketSyncServiceProvider);
    final storage = ref.read(localStorageServiceProvider);

    _wsAnniversarySub = ws.onEvent('ANNIVERSARY_UPDATED').listen((e) async {
      final data = e.data;
      final dateStr = data['anniversaryDate']?.toString() ??
          data['startDate']?.toString();
      DateTime? parsed;
      if (dateStr != null && dateStr.isNotEmpty) {
        parsed = DateTime.tryParse(dateStr)?.toUtc();
      }

      final serverTimeStr = data['serverTime']?.toString();
      final serverTime = serverTimeStr != null
          ? DateTime.tryParse(serverTimeStr)?.toUtc()
          : null;

      if (parsed != null) {
        final daysTogether = (data['daysTogether'] as num?)?.toInt() ??
            AnniversaryDateUtils.calculateDaysTogether(parsed, serverTime: serverTime);

        await storage.setAnniversaryDate(parsed);
        await storage.setDaysTogether(daysTogether);

        final sorted = _computeNextMilestone(state.milestones, serverTime: serverTime);

        state = state.copyWith(
          daysTogether: daysTogether,
          officialStartDate: parsed,
          serverTime: serverTime,
          nextMilestone: sorted.next,
          daysUntilNextMilestone: sorted.days,
        );
      }
    });

    _wsMilestoneAddedSub = ws.onEvent('MILESTONE_ADDED').listen((e) {
      _loadMilestones();
    });

    _wsMilestoneDeletedSub = ws.onEvent('MILESTONE_DELETED').listen((e) {
      _loadMilestones();
    });

    _wsPairedSub = ws.onEvent('COUPLE_PAIRED').listen((e) {
      syncAnniversaryFromBackend();
    });
  }

  /// Synchronizes the exact official start date and duration from the backend on app initialization
  Future<void> syncAnniversaryFromBackend() async {
    final user = ref.read(authStateProvider);
    final spaceId = user?.coupleSpaceId;
    if (spaceId == null || spaceId.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final pairingRepo = ref.read(pairingRepositoryProvider);
      final result = await pairingRepo.getCoupleSummary(
        coupleSpaceId: spaceId,
        userId: user?.id,
      );

      await result.fold(
        (failure) async {
          debugPrint('[AnniversaryNotifier] Backend summary sync warning: ${failure.message}');
          await _loadMilestones();
        },
        (summary) async {
          await syncFromSummary(summary);
          await _loadMilestones();
        },
      );
    } catch (e) {
      debugPrint('[AnniversaryNotifier] Error syncing anniversary from backend: $e');
      await _loadMilestones();
    }
  }

  /// Ingests couple summary and recalculates exact start date and days together
  Future<void> syncFromSummary(CoupleSummary summary) async {
    final storage = ref.read(localStorageServiceProvider);
    final officialStart = summary.officialStartDate;
    if (officialStart == null) return;

    final days = summary.daysTogether > 0
        ? summary.daysTogether
        : AnniversaryDateUtils.calculateDaysTogether(
            officialStart,
            serverTime: summary.serverTime,
          );

    await storage.setAnniversaryDate(officialStart);
    await storage.setDaysTogether(days);

    final sorted = _computeNextMilestone(state.milestones, serverTime: summary.serverTime);

    state = state.copyWith(
      daysTogether: days,
      officialStartDate: officialStart,
      serverTime: summary.serverTime,
      nextMilestone: sorted.next,
      daysUntilNextMilestone: sorted.days,
    );
  }

  Future<void> _loadMilestones() async {
    final user = ref.read(authStateProvider);
    final spaceId = user?.coupleSpaceId;
    if (spaceId == null || spaceId.isEmpty) {
      state = state.copyWith(isLoading: false, milestones: const []);
      return;
    }
    final repo = ref.read(anniversaryRepositoryProvider);

    final result = await repo.getMilestones(spaceId);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false),
      (list) {
        final sorted = _computeNextMilestone(list, serverTime: state.serverTime);
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
    List<AnniversaryMilestone> milestones, {
    DateTime? serverTime,
  }) {
    if (milestones.isEmpty) return (next: null, days: null);

    final currentUtc = (serverTime ?? DateTime.now()).toUtc();

    AnniversaryMilestone? closest;
    int minDays = 999999;

    for (final m in milestones) {
      final daysUntil = AnniversaryDateUtils.calculateDaysUntil(
        m.targetDate,
        isRecurringAnnual: m.isRecurringAnnual,
        serverTime: currentUtc,
      );

      if (daysUntil < minDays) {
        minDays = daysUntil;
        closest = m;
      }
    }

    return (next: closest, days: minDays == 999999 ? null : minDays);
  }

  /// Updates the official anniversary date on the backend and broadcasts to both devices
  Future<bool> updateAnniversaryDate(DateTime newDate) async {
    final user = ref.read(authStateProvider);
    final spaceId = user?.coupleSpaceId;
    if (spaceId == null || spaceId.isEmpty) return false;

    final storage = ref.read(localStorageServiceProvider);
    final utcDate = newDate.toUtc();
    final newDays = AnniversaryDateUtils.calculateDaysTogether(utcDate);

    // Optimistic local update
    await storage.setAnniversaryDate(utcDate);
    await storage.setDaysTogether(newDays);
    state = state.copyWith(
      officialStartDate: utcDate,
      daysTogether: newDays,
    );

    try {
      final pairingRepo = ref.read(pairingRepositoryProvider);
      final result = await pairingRepo.updateAnniversaryDate(
        coupleSpaceId: spaceId,
        anniversaryDate: utcDate,
      );

      return await result.fold(
        (failure) async {
          debugPrint('[AnniversaryNotifier] Update anniversary failed: ${failure.message}');
          return false;
        },
        (summary) async {
          await syncFromSummary(summary);
          return true;
        },
      );
    } catch (e) {
      debugPrint('[AnniversaryNotifier] Error updating anniversary date: $e');
      return false;
    }
  }

  Future<bool> addMilestone({
    required String title,
    required DateTime targetDate,
    required bool isRecurringAnnual,
    required String iconEmoji,
    String? note,
  }) async {
    final user = ref.read(authStateProvider);
    final spaceId = user?.coupleSpaceId;
    if (spaceId == null || spaceId.isEmpty) return false;
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
        final sorted = _computeNextMilestone(updatedList, serverTime: state.serverTime);
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
