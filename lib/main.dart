import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './core/constants/app_strings.dart';
import './core/theme/theme_notifier.dart';
import './services/external_api_service.dart';
import './services/supabase_service.dart';
import 'core/app_export.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  ExternalApiService.instance.initialize();
  runApp(const CollabFutureApp());
}

class CollabFutureApp extends StatefulWidget {
  const CollabFutureApp({super.key});
  @override
  State<CollabFutureApp> createState() => _CollabFutureAppState();
}

class _CollabFutureAppState extends State<CollabFutureApp> {
  late final ThemeNotifier _themeNotifier;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ThemeNotifier();
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: _themeNotifier,
          builder: (context, themeMode, child) {
            return MaterialApp(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              initialRoute: AppRoutes.splashScreen,
              routes: AppRoutes.routes,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(1.0),
                  ),
                  child: child!,
                );
              },
            );
          },
        );
      },
    );
  }
}
