import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/router/app_router.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/core/theme/app_theme.dart';
import 'package:thae_nge_lay/features/auth/presentation/listeners/single_device_security_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  final localStorage = LocalStorageService();
  await localStorage.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorage),
      ],
      child: const ScreenUtilInit(
        designSize: Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        child: ThaeThaeApp(),
      ),
    ),
  );
}

class ThaeThaeApp extends ConsumerWidget {
  const ThaeThaeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(singleDeviceSecurityListenerProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Thae Thae',
      debugShowCheckedModeBanner: false,
      theme: BelieveTheme.lightTheme,
      routerConfig: router,
    );
  }
}

typedef BelieveUsApp = ThaeThaeApp;
