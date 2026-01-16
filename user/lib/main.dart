import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_wrapper.dart';
import 'constants/app_constants.dart';
import 'services/language_service.dart';
import 'services/animal_similarity_api.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize language service
  final languageService = LanguageService();
  await languageService.initialize();

  // Check AI API health (non-blocking)
  _checkAIAPIHealth();

  runApp(PatiWorldApp(languageService: languageService));
}

/// Check if AI API is available (runs in background)
Future<void> _checkAIAPIHealth() async {
  try {
    final response = await AnimalSimilarityAPI.checkHealth();
    if (response.success) {
      print('✅ AI API is ready and connected!');
    } else {
      print('⚠️ AI API is not available. Text-based matching will be used.');
      print(
        '   To enable AI: Run "python api_server.py" in model_project folder',
      );
    }
  } catch (e) {
    print('⚠️ Could not check AI API health: $e');
    print('   AI features will use text-based matching as fallback.');
  }
}

class PatiWorldApp extends StatelessWidget {
  final LanguageService languageService;

  const PatiWorldApp({super.key, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LanguageService>(
      create: (_) => languageService,
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: 'PatiWorld',
            debugShowCheckedModeBanner: false,

            // Localization configuration
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageService.supportedLocales,
            locale: languageService.currentLocale,
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale != null) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }
              }
              return languageService.currentLocale;
            },

            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7D32), // Hayvanlar için yeşil renk
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
