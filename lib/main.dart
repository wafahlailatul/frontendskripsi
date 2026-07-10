import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:kesehatan_jantung/app/background/background_service.dart';
import 'package:kesehatan_jantung/app/modules/landing_page/views/landing_page_view.dart';
import 'package:kesehatan_jantung/app/services/reminder_service.dart'; // 1. IMPORT SERVICE PENGINGAT
import 'firebase_options.dart';

Future<void> main() async {
  // Memastikan semua binding Flutter siap sebelum eksekusi fungsi async
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inisialisasi Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Inisialisasi Background Service bawaan Anda
    await BackgroundService.initialize();

    // 2. INISIALISASI SYSTEM NOTIFIKASI & TIMEZONE (Agar Tambah Pengingat Tidak Eror)
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
    // Tetap menggunakan GetMaterialApp sesuai arsitektur proyek Anda
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