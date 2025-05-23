import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMob temporarily disabled
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'services/question_service.dart';
import 'services/settings/language_service.dart';
import 'services/revenue_cat_service.dart';
import 'themes/app_themes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'features/camp_mode/screens/camp_intro_screen.dart';
import 'features/camp_mode/screens/camp_day_screen.dart';
import 'features/camp_mode/screens/camp_progress_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'utils/app_localizations_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Uygulama başlatılıyor...');
  
  // SharedPreferences başlat - onboarding durumu için
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
    print('✅ SharedPreferences başlatıldı');
  } catch (e) {
    print('⚠️ SharedPreferences hatası: $e');
  }
  
  final bool showOnboarding = !(prefs?.getBool('onboarding_completed') ?? false);
  
  // RevenueCat'i başlat (error handling ile)
  try {
    await RevenueCatService.initialize();
    print('✅ RevenueCat başlatıldı');
  } catch (e) {
    print('⚠️ RevenueCat başlatılamadı: $e');
    // Uygulama RevenueCat olmadan da çalışabilir
  }
  
  // AdMob başlatma kaldırıldı - geçici olarak devre dışı
  /*
  try {
    await MobileAds.instance.initialize();
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['57885BC4644BB657C9A87611E116BFAF']),
    );
    print('✅ AdMob başlatıldı');
  } catch (e) {
    print('⚠️ AdMob başlatılamadı: $e');
  }
  */
  print('⚠️ AdMob geçici olarak devre dışı');
  
  // Dil servisini başlat
  LanguageService? languageService;
  try {
    languageService = LanguageService();
    await languageService.init();
    print('✅ Language service başlatıldı');
  } catch (e) {
    print('⚠️ Language service hatası: $e');
    languageService = LanguageService(); // Fallback
  }
  
  // Global AppLocalizationsProvider'ı başlat
  try {
    await appLocalizationsProvider.initialize(languageService.currentLocale.value);
    print('✅ Localization başlatıldı');
  } catch (e) {
    print('⚠️ Localization hatası: $e');
  }
  
  // Uygulama başlatılmadan önce soruları yükle
  final questionService = QuestionService();
  try {
    await questionService.loadQuestions();
    print('✅ Sorular yüklendi: ${questionService.getAllQuestions().length} soru');
  } catch (e) {
    print('❌ KRITIK: Sorular yüklenirken hata oluştu: $e');
    // Bu kritik bir hata, ancak uygulama yine de başlasın
  }
  
  // Ekran yönünü portre olarak sabitle
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    print('✅ Screen orientation ayarlandı');
  } catch (e) {
    print('⚠️ Screen orientation ayarlanamadı: $e');
  }
  
  print('🎯 Uygulama UI başlatılıyor...');
  
  runApp(MyApp(
    questionService: questionService,
    languageService: languageService,
    showOnboarding: showOnboarding,
  ));
}

class MyApp extends StatefulWidget {
  final QuestionService questionService;
  final LanguageService languageService;
  final bool showOnboarding;
  
  const MyApp({
    Key? key, 
    required this.questionService,
    required this.languageService,
    required this.showOnboarding,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    print('📱 MyApp widget başlatıldı');
    // Dil değişimlerini dinle
    widget.languageService.currentLocale.addListener(_onLocaleChange);
  }

  @override
  void dispose() {
    // Dinleyiciyi kaldır
    widget.languageService.currentLocale.removeListener(_onLocaleChange);
    super.dispose();
  }

  // Dil değişiminde state'i güncelle
  void _onLocaleChange() {
    setState(() {});
    // Global AppLocalizationsProvider'ı güncelle
    appLocalizationsProvider.updateLocale(widget.languageService.currentLocale.value);
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 MaterialApp build ediliyor...');
    
    return MaterialApp(
      title: 'US Citizenship Test',
      debugShowCheckedModeBanner: false,
      locale: widget.languageService.currentLocale.value,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('tr'), // Turkish
      ],
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      // İlk çalıştırmada Onboarding ekranını göster
      initialRoute: widget.showOnboarding ? '/onboarding' : '/',
      routes: {
        '/': (context) {
          print('🏠 HomeScreen yükleniyor...');
          return HomeScreen(
            questionService: widget.questionService,
            languageService: widget.languageService,
          );
        },
        '/onboarding': (context) {
          print('👋 OnboardingScreen yükleniyor...');
          return const OnboardingScreen();
        },
        '/camp_mode': (context) => const CampIntroScreen(),
        '/camp_progress': (context) => const CampProgressScreen(),
      },
      onGenerateRoute: (settings) {
        print('🔄 Route generate: ${settings.name}');
        if (settings.name == '/camp_day') {
          final dayNumber = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => CampDayScreen(dayNumber: dayNumber),
          );
        }
        return null;
      },
    );
  }
}
