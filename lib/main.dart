import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/quote_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  final storageService = StorageService();
  final notificationService = NotificationService();
  final quoteService = QuoteService();
  
  // Initialize services
  await storageService.init();
  await notificationService.init(storageService);
  await quoteService.loadQuotes();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<NotificationService>.value(value: notificationService),
        Provider<QuoteService>.value(value: quoteService),
      ],
      child: const StudentSchedulerApp(),
    ),
  );
}

class StudentSchedulerApp extends StatelessWidget {
  const StudentSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Scheduler',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
} 