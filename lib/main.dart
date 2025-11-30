import 'package:flutter/material.dart';
import 'utils/palette.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/premium_screen.dart';
import 'services/user_status_service.dart';
import 'services/settings_service.dart';
import 'database/hive_database.dart';
import 'services/in_app_notification_service.dart';
import 'services/notification_service.dart';
import 'package:flutter/widgets.dart';

// Global route observer used by screens that want to know when they become visible.
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inisialisasi Hive
  await Hive.initFlutter();

  // Pastikan box utama terbuka sebelum digunakan
  await Hive.openBox('userBox');

  // (Opsional) Debug print, kalau mau cek isi box saat startup
  final db = HiveDatabase();
  await db.printAllUsers();

  // 🔹 Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // 🔹 SharedPreferences
  await SharedPreferences.getInstance();

  // 🔹 App settings
  // Initialize persisted settings (allow_location, allow_notifications)
  await SettingsService.init();

  // 🔹 In-app notifications store
  await InAppNotificationService.init();

  // 🔹 Initialize local/OS notifications (request permissions etc.)
  await NotificationService.init();

  // 🔹 Ambil status user
  final isPremium = await UserStatusService.isPremium();
  final username = await UserStatusService.getUsername();

  runApp(EjaMateApp(isPremium: isPremium, username: username ?? 'Pengguna'));
}

class EjaMateApp extends StatelessWidget {
  final bool isPremium;
  final String username;

  const EjaMateApp({
    super.key,
    required this.isPremium,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EjaMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primary swatch kept default but use primary color for App theme
        primaryColor: Palette.primary,
        scaffoldBackgroundColor: Palette.background,
        appBarTheme: const AppBarTheme(backgroundColor: Palette.primaryDark),
        colorScheme: ColorScheme.fromSeed(seedColor: Palette.primary, primary: Palette.primary, secondary: Palette.accent),
      ),
      navigatorObservers: [routeObserver],
      home: isPremium
          ? PremiumScreen(username: username)
          : const SplashScreen(),
    );
  }
}
