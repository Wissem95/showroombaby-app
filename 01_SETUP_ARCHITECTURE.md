# 🚀 Setup & Architecture Flutter - ShowroomBaby

## Configuration du Projet

Créez un nouveau projet Flutter avec l'architecture suivante :

```
lib/
├── main.dart
├── app/
│   ├── routes/
│   │   └── app_router.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   └── constants/
│       ├── api_constants.dart
│       └── app_constants.dart
├── core/
│   ├── models/
│   ├── providers/
│   ├── services/
│   └── utils/
├── features/
│   ├── auth/
│   ├── home/
│   ├── products/
│   ├── profile/
│   ├── messages/
│   ├── favorites/
│   └── search/
└── shared/
    ├── widgets/
    └── extensions/
```

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Navigation
  go_router: ^12.1.3

  # HTTP & Networking
  dio: ^5.4.0
  retrofit: ^4.0.3
  json_annotation: ^4.8.1

  # Data persistence
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # UI & UX
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4
  permission_handler: ^11.1.0
  geolocator: ^10.1.0

  # Utils
  freezed_annotation: ^2.4.1
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code generation
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  retrofit_generator: ^8.0.4
  hive_generator: ^2.0.1
```

## Configuration Riverpod (main.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/routes/app_router.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Hive pour le stockage local
  await Hive.initFlutter();

  runApp(
    ProviderScope(
      child: ShowroomBabyApp(),
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
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

## Constantes API (api_constants.dart)

```dart
class ApiConstants {
  static const String baseUrl = 'YOUR_BACKEND_URL/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String checkAuth = '/auth/check';

  // Products endpoints
  static const String products = '/products';
  static const String trending = '/products/trending';

  // Categories endpoints
  static const String categories = '/categories';

  // Messages endpoints
  static const String messages = '/messages';
  static const String conversations = '/messages/conversations';

  // Favorites endpoints
  static const String favorites = '/favorites';

  // Users endpoints
  static const String profile = '/users/profile';

  // Reports endpoints
  static const String reports = '/reports';
}
```

## Thème de l'application (app_theme.dart)

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Poppins',

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
    );
  }
}
```

## Couleurs (app_colors.dart)

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFFFF9800);
  static const Color accent = Color(0xFF4CAF50);

  // Couleurs de fond
  static const Color background = Color(0xFFF8F9FA);
  static const Color darkBackground = Color(0xFF121212);
  static const Color surface = Colors.white;

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);

  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Couleurs de bordure
  static const Color border = Color(0xFFE0E0E0);

  // Couleurs spécifiques à l'app
  static const Color favorite = Color(0xFFE91E63);
  static const Color price = Color(0xFF4CAF50);
}
```

## Instructions de démarrage

1. Créez le projet Flutter avec `flutter create showroombaby_app`
2. Remplacez le contenu de `pubspec.yaml` avec les dépendances ci-dessus
3. Exécutez `flutter pub get`
4. Créez la structure de dossiers selon l'architecture proposée
5. Implémentez les fichiers de base (main.dart, thème, constantes)
6. Configurez l'URL de votre backend dans `api_constants.dart`
7. Exécutez `flutter pub run build_runner build` pour générer le code

L'architecture est maintenant prête pour implémenter les fonctionnalités !
