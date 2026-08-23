import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/login_view.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:camera/camera.dart';

import 'package:firebase_core/firebase_core.dart';
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initializes Firebase for the current platform
  await dotenv.load(fileName: ".env");
  
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error fetching cameras: $e');
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const LensMatchApp(),
    ),
  );
}

class LensMatchApp extends StatelessWidget {
  const LensMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Restore the premium custom color palette
    const Color bgPrimary = Color(0xFF0A0A0A); // Very deep charcoal/black
    const Color bgCard = Color(0xFF141414); // Slightly lighter for cards
    const Color textPrimary = Color(0xFFF9F6EE); // Off-white/pearl
    const Color textSecondary = Color(0xFFAFAFAF); // Silver/gray
    const Color accentColor = Color(0xFFD4AF37); // Metallic Gold

    return MaterialApp(
      title: 'LensMatch',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgPrimary,
        primaryColor: accentColor,
        colorScheme: const ColorScheme.dark(
          primary: accentColor,
          surface: bgCard,
          onSurface: textPrimary,
          onSurfaceVariant: textSecondary,
        ),
        cardColor: bgCard,
        cardTheme: CardThemeData(
          color: bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF2A2A35), width: 1), // subtle border
          ),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: bgCard,
          selectedItemColor: accentColor,
          unselectedItemColor: textPrimary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
          displayMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
          displaySmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
          headlineLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
          headlineMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
          headlineSmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
          titleSmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),

          bodyLarge: GoogleFonts.inter(color: textPrimary),
          bodyMedium: GoogleFonts.inter(color: textPrimary),
          bodySmall: GoogleFonts.inter(color: textSecondary),
          labelLarge: GoogleFonts.inter(color: textPrimary),
          labelMedium: GoogleFonts.inter(color: textSecondary),
          labelSmall: GoogleFonts.inter(color: textSecondary),
        ),
      ),
      home: const LoginView(),
    );
  }
}

