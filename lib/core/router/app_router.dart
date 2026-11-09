import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/screens/anniversary_screen.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/auth/presentation/screens/login_screen.dart';
import 'package:thae_nge_lay/features/auth/presentation/screens/otp_verify_screen.dart';
import 'package:thae_nge_lay/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:thae_nge_lay/features/chat/presentation/screens/chat_screen.dart';
import 'package:thae_nge_lay/features/emergency/domain/models/emergency_sos_model.dart';
import 'package:thae_nge_lay/features/emergency/presentation/screens/emergency_alarm_screen.dart';
import 'package:thae_nge_lay/features/gifting/presentation/screens/payment_callback_handler_screen.dart';
import 'package:thae_nge_lay/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:thae_nge_lay/features/location/presentation/controllers/location_permission_controller.dart';
import 'package:thae_nge_lay/features/location/presentation/screens/location_permission_required_screen.dart';
import 'package:thae_nge_lay/features/location/presentation/screens/partner_map_screen.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/screens/partner_location_detail_screen.dart';
import 'package:thae_nge_lay/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:thae_nge_lay/features/pairing/presentation/screens/pairing_screen.dart';
import 'package:thae_nge_lay/features/settings/presentation/screens/contact_us_screen.dart';
import 'package:thae_nge_lay/features/settings/presentation/screens/settings_screen.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'rootNav');

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final storage = ref.watch(localStorageServiceProvider);
  final user = ref.watch(authStateProvider);
  final isLocationGranted = ref.watch(locationPermissionControllerProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: storage.isOnboardingCompleted
        ? AppRoutes.login
        : AppRoutes.onboarding,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isOnboardingCompleted = storage.isOnboardingCompleted;
      final currentPath = state.matchedLocation;

      // 1. Onboarding Guard
      if (!isOnboardingCompleted) {
        if (currentPath != AppRoutes.onboarding) {
          return AppRoutes.onboarding;
        }
        return null;
      }

      if (currentPath == AppRoutes.onboarding && isOnboardingCompleted) {
        return AppRoutes.login;
      }

      // 2. Authentication Guard
      final isAuthRoute = currentPath == AppRoutes.login ||
          currentPath == AppRoutes.otpVerify;

      if (user == null) {
        if (!isAuthRoute) {
          return AppRoutes.login;
        }
        return null;
      }

      // 3. User Profile Completion Guard
      if (!user.isProfileComplete) {
        if (currentPath != AppRoutes.profileSetup) {
          return AppRoutes.profileSetup;
        }
        return null;
      }

      // 4. Strict 1-to-1 Couple Pairing Guard
      final isPaired = user.partnerId != null && user.coupleSpaceId != null;
      if (!isPaired) {
        if (currentPath != AppRoutes.pairing) {
          return AppRoutes.pairing;
        }
        return null;
      }

      // 5. Mandatory Location Guard (Specification #3)
      if (!isLocationGranted) {
        if (currentPath != AppRoutes.locationGuard) {
          return AppRoutes.locationGuard;
        }
        return null;
      }

      // 6. Redirect authenticated & paired users away from entry screens
      if (isAuthRoute ||
          currentPath == AppRoutes.onboarding ||
          currentPath == AppRoutes.pairing ||
          currentPath == AppRoutes.profileSetup ||
          currentPath == AppRoutes.locationGuard) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerify,
        builder: (context, state) {
          final email = state.extra as String? ?? (state.uri.queryParameters['email'] ?? '');
          return OtpVerifyScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.pairing,
        builder: (context, state) => const PairingScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationGuard,
        builder: (context, state) => const LocationPermissionRequiredScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const ChatScreen(hasBottomNavBar: false),
      ),
      GoRoute(
        path: AppRoutes.map,
        builder: (context, state) => const PartnerMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationDetails,
        builder: (context, state) => const PartnerLocationDetailScreen(),
      ),
      GoRoute(
        path: AppRoutes.anniversary,
        builder: (context, state) => const AnniversaryScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.contactUs,
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: AppRoutes.emergencyAlarm,
        builder: (context, state) {
          final alert = state.extra as EmergencySOSModel?;
          return EmergencyAlarmScreen(alert: alert);
        },
      ),
      GoRoute(
        path: AppRoutes.paymentCallback,
        builder: (context, state) {
          final queryParams = state.uri.queryParameters;
          return PaymentCallbackHandlerScreen(
            status: queryParams['status'] ?? 'success',
            orderId: queryParams['orderId'],
            transactionRef:
                queryParams['txnRef'] ?? queryParams['transactionRef'],
            provider: queryParams['provider'],
          );
        },
      ),
    ],
  );
}
