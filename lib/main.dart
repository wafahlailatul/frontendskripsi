import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kesehatan_jantung/app/background/background_service.dart';
import 'package:kesehatan_jantung/app/modules/landing_page/views/landing_page_view.dart';
import 'package:kesehatan_jantung/app/modules/onboarding/onboarding_view.dart';
import 'package:kesehatan_jantung/app/services/reminder_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await BackgroundService.initialize();
    await ReminderService.init();
  } catch (e) {
    print("Eror saat inisialisasi aplikasi: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Heartify',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
      ),
      home: const LandingPageView(),
    );
  }
}