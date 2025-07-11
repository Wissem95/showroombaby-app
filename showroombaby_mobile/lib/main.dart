import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/routes/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/providers/base_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser SharedPreferences dès le début
  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) => Future.value(sharedPreferences)),
      ],
      child: const ShowroomBabyApp(),
    ),
  );
}

class ShowroomBabyApp extends ConsumerWidget {
  const ShowroomBabyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ShowroomBaby',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
