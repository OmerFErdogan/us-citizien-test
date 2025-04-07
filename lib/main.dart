import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'services/question_service.dart';
import 'services/settings/language_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'features/camp_mode/screens/camp_intro_screen.dart';
import 'features/camp_mode/screens/camp_day_screen.dart';
import 'features/camp_mode/screens/camp_progress_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Dil servisini başlat
  final languageService = LanguageService();
  await languageService.init();
  
  // Uygulama başlatılmadan önce soruları yükle
  final questionService = QuestionService();
  try {
    await questionService.loadQuestions();
  } catch (e) {
    print('Sorular yüklenirken hata oluştu: $e');
    // Hata durumunda bile uygulamayı başlat, UI'da bir hata mesajı gösterilecek
  }
  
  // Ekran yönünü portre olarak sabitle
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(MyApp(
    questionService: questionService,
    languageService: languageService,
  ));
}

class MyApp extends StatefulWidget {
  final QuestionService questionService;
  final LanguageService languageService;
  
  const MyApp({
    Key? key, 
    required this.questionService,
    required this.languageService,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'US Citizenship Dream',
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.red,
          tertiary: Colors.white,
          surface: Colors.blueGrey[900]!,
          background: Colors.blueGrey[900]!,
        ),
      ),
      debugShowCheckedModeBanner: false,
      locale: widget.languageService.currentLocale.value, // Dil servisinden al
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.red,
          tertiary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(
          questionService: widget.questionService,
          languageService: widget.languageService,
        ),
        '/camp_mode': (context) => const CampIntroScreen(),
        '/camp_progress': (context) => const CampProgressScreen(),
      },
      onGenerateRoute: (settings) {
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