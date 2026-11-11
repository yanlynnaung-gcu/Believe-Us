import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/router/app_router.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';

class SingleDeviceSecurityListener {
  final Ref ref;
  StreamSubscription? _attemptSub;
  StreamSubscription? _terminatedSub;
  bool _isDialogShowing = false;

  SingleDeviceSecurityListener(this.ref) {
    _init();
  }

  void _init() {
    final ws = ref.read(webSocketSyncServiceProvider);

    _attemptSub?.cancel();
    _attemptSub = ws.onEvent('DEVICE_LOGIN_ATTEMPT').listen((e) {
      _handleLoginAttempt(e.data);
    });

    _terminatedSub?.cancel();
    _terminatedSub = ws.onEvent('SESSION_TERMINATED').listen((e) {
      _handleSessionTerminated(e.data);
    });
  }

  void _handleLoginAttempt(Map<String, dynamic> data) {
    final ticketId = data['ticketId']?.toString();
    final deviceName = data['deviceName']?.toString() ?? 'Another Device';

    if (ticketId == null || ticketId.isEmpty || _isDialogShowing) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    _isDialogShowing = true;

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.security_rounded, color: BelieveColors.primary),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Allow other device login?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new login attempt from "$deviceName" was detected.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              'If you allow this login, your current session on this device will be logged out.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop(false);
              await _resolveTicket(ticketId, approved: false);
            },
            child: const Text('Deny', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: BelieveColors.primary,
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop(true);
              await _resolveTicket(ticketId, approved: true);
              await ref.read(authStateProvider.notifier).logout();
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  Future<void> _resolveTicket(String ticketId, {required bool approved}) async {
    try {
      final dio = ref.read(dioClientProvider);
      await dio.post(
        ApiEndpoints.authLoginTicketResolvePath(ticketId),
        data: {'approved': approved},
      );
    } catch (_) {}
  }

  void _handleSessionTerminated(Map<String, dynamic> data) async {
    final deviceName = data['deviceName']?.toString() ?? 'another device';
    await ref.read(authStateProvider.notifier).logout();

    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session signed out: logged in from $deviceName.'),
          backgroundColor: BelieveColors.primary,
        ),
      );
    }
  }

  void dispose() {
    _attemptSub?.cancel();
    _terminatedSub?.cancel();
  }
}

final singleDeviceSecurityListenerProvider =
    Provider<SingleDeviceSecurityListener>((ref) {
  final listener = SingleDeviceSecurityListener(ref);
  ref.onDispose(() => listener.dispose());
  return listener;
});
