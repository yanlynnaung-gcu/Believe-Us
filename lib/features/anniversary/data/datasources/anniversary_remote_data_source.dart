import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/features/anniversary/domain/models/anniversary_milestone.dart';

abstract interface class AnniversaryRemoteDataSource {
  Future<List<AnniversaryMilestone>> getMilestones(String coupleSpaceId);
  Future<AnniversaryMilestone> addMilestone({
    required String coupleSpaceId,
    required String title,
    required DateTime targetDate,
    required bool isRecurringAnnual,
    required String iconEmoji,
    String? note,
  });
  Future<void> deleteMilestone(String milestoneId);
}

class AnniversaryRemoteDataSourceImpl implements AnniversaryRemoteDataSource {
  final Dio? _dio;
  final Uuid _uuid = const Uuid();

  static final Map<String, List<AnniversaryMilestone>> _milestonesStore = {};

  AnniversaryRemoteDataSourceImpl({Dio? dio}) : _dio = dio {
    _seedDefaultMilestones();
  }

  void _seedDefaultMilestones() {
    if (_milestonesStore.isEmpty) {
      const defaultSpaceId = 'space_demo';
      final now = DateTime.now();

      _milestonesStore[defaultSpaceId] = [
        AnniversaryMilestone(
          id: 'ms_seed_1',
          title: 'The Day We Said Yes ❤️',
          targetDate: DateTime(now.year - 1, 10, 24),
          isRecurringAnnual: true,
          iconEmoji: '💍',
          note: 'The most sacred day when our journey began',
          category: 'Annual Anniversary',
        ),
        AnniversaryMilestone(
          id: 'ms_seed_2',
          title: 'First Flight Visit & Warmest Hug',
          targetDate: DateTime(now.year, 12, 15),
          isRecurringAnnual: false,
          iconEmoji: '✈️',
          note: 'Yangon to Mandalay flight reunion',
          category: 'Trip Countdown',
        ),
        AnniversaryMilestone(
          id: 'ms_seed_3',
          title: 'Valentine\'s Day Celebration',
          targetDate: DateTime(now.year + 1, 2, 14),
          isRecurringAnnual: true,
          iconEmoji: '💌',
          note: 'Romantic virtual candle date & special gifts',
          category: 'Holiday',
        ),
      ];
    }
  }

  List<AnniversaryMilestone> _getList(String coupleSpaceId) {
    return _milestonesStore.putIfAbsent(coupleSpaceId, () => []);
  }

  @override
  Future<List<AnniversaryMilestone>> getMilestones(String coupleSpaceId) async {
    if (_dio != null) {
      try {
        final response = await _dio.get(
          ApiEndpoints.milestonesPath,
          queryParameters: {'coupleSpaceId': coupleSpaceId},
        );
        if (response.statusCode == 200 && response.data is List) {
          final list = (response.data as List).map((raw) {
            final json = raw as Map<String, dynamic>;
            return AnniversaryMilestone(
              id: json['id'] as String? ?? 'ms_${_uuid.v4().substring(0, 8)}',
              title: json['title'] as String? ?? '',
              targetDate: json['targetDate'] != null
                  ? DateTime.parse(json['targetDate'].toString())
                  : DateTime.now(),
              isRecurringAnnual: json['isRecurringAnnual'] as bool? ?? true,
              iconEmoji: json['iconEmoji'] as String? ?? '❤️',
              note: json['note'] as String?,
              category: json['category'] as String? ?? 'Anniversary',
            );
          }).toList();

          _milestonesStore[coupleSpaceId] = list;
          return list;
        }
      } catch (_) {
        // Fallback to local store on network or mock conditions
      }
    }

    await Future.delayed(const Duration(milliseconds: 100));
    final list = _getList(coupleSpaceId);
    return List<AnniversaryMilestone>.from(list);
  }

  @override
  Future<AnniversaryMilestone> addMilestone({
    required String coupleSpaceId,
    required String title,
    required DateTime targetDate,
    required bool isRecurringAnnual,
    required String iconEmoji,
    String? note,
  }) async {
    final milestone = AnniversaryMilestone(
      id: 'ms_${_uuid.v4().substring(0, 8)}',
      title: title,
      targetDate: targetDate,
      isRecurringAnnual: isRecurringAnnual,
      iconEmoji: iconEmoji,
      note: note,
    );

    if (_dio != null) {
      try {
        final payload = {
          'id': milestone.id,
          'coupleSpaceId': coupleSpaceId,
          'title': title,
          'targetDate': targetDate.toIso8601String(),
          'isRecurringAnnual': isRecurringAnnual,
          'iconEmoji': iconEmoji,
          'note': note,
        };
        final response = await _dio.post(
          ApiEndpoints.milestonesPath,
          data: payload,
          queryParameters: {'coupleSpaceId': coupleSpaceId},
        );
        if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
          final resJson = response.data as Map<String, dynamic>;
          final serverMilestone = AnniversaryMilestone(
            id: resJson['id'] as String? ?? milestone.id,
            title: resJson['title'] as String? ?? title,
            targetDate: resJson['targetDate'] != null
                ? DateTime.parse(resJson['targetDate'].toString())
                : targetDate,
            isRecurringAnnual: resJson['isRecurringAnnual'] as bool? ?? isRecurringAnnual,
            iconEmoji: resJson['iconEmoji'] as String? ?? iconEmoji,
            note: resJson['note'] as String? ?? note,
            category: resJson['category'] as String? ?? 'Anniversary',
          );
          _getList(coupleSpaceId).add(serverMilestone);
          return serverMilestone;
        }
      } catch (_) {
        // Fallback to local store on offline
      }
    }

    await Future.delayed(const Duration(milliseconds: 100));
    _getList(coupleSpaceId).add(milestone);
    return milestone;
  }

  @override
  Future<void> deleteMilestone(String milestoneId) async {
    if (_dio != null) {
      try {
        await _dio.delete('${ApiEndpoints.milestonesPath}/$milestoneId');
      } catch (_) {}
    }

    for (final list in _milestonesStore.values) {
      list.removeWhere((m) => m.id == milestoneId);
    }
  }
}
