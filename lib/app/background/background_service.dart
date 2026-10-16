import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class BackgroundService {
  static final FlutterBackgroundService service = FlutterBackgroundService();
  static final FlutterLocalNotificationsPlugin notification = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'activity_channel',
      'Aktivitas Fisik',
      description: 'Channel untuk tracking langkah dan rute olahraga',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
      'alarm_target_channel',
      'Alarm Target Olahraga',
      description: 'Channel khusus untuk alarm saat target olahraga sukses tercapai',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = notification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.createNotificationChannel(alarmChannel);

    await notification.initialize(
      const InitializationSettings(android: androidSettings),
    );

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        foregroundServiceNotificationId: 100,
        initialNotificationTitle: "Aktivitas Fisik",
        initialNotificationContent: "Memulai pelacakan...",
        notificationChannelId: 'activity_channel',
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  static Future<bool> start() async {
    // 1. Cek & Minta Izin Notifikasi
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }
    
    // 2. Cek & Minta Izin Sensor Gerak dan Lokasi (Saat Digunakan)
    if (!await Permission.activityRecognition.isGranted || 
        !await Permission.locationWhenInUse.isGranted) {
      await [
        Permission.activityRecognition,
        Permission.locationWhenInUse,
      ].request();
    }

    bool activityGranted = await Permission.activityRecognition.isGranted;
    bool locationGranted = await Permission.locationWhenInUse.isGranted;

    // 3. Jika izin dasar diberikan, jalankan service
    if (activityGranted && locationGranted) {
      // Minta locationAlways secara terpisah HANYA JIKA belum diizinkan
      if (!await Permission.locationAlways.isGranted) {
        await Permission.locationAlways.request();
      }
      return await service.startService();
    }
    return false;
  }

  static Future<void> stop() async {
    service.invoke("stop");
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  int langkahAwal = -1;
  int langkah = 0;
  double jarak = 0;
  double kecepatan = 0;
  int targetLangkah = 7000;
  bool alarmTriggered = false;

  Position? posisiSebelumnya;
  DateTime mulai = DateTime.now();
  Timer? timer;

  StreamSubscription<StepCount>? stepSubscription;
  StreamSubscription<Position>? gpsSubscription;

  void paksaUpdateNotifikasiAndroid() {
    if (service is AndroidServiceInstance) {
      Duration durasi = DateTime.now().difference(mulai);
      String menit = "${durasi.inMinutes % 60}".padLeft(2, '0');
      String detik = "${durasi.inSeconds % 60}".padLeft(2, '0');

      service.setForegroundNotificationInfo(
        title: "Kardio Aktif: $langkah / $targetLangkah Langkah",
        content: "📍 ${jarak.toStringAsFixed(2)} km | ⏱ $menit:$detik | 🚶 ${kecepatan.toStringAsFixed(1)} km/j",
      );
    }
  }

  // Tampilkan notifikasi awal secara langsung
  paksaUpdateNotifikasiAndroid();

  service.on("setTarget").listen((event) {
    if (event != null && event["targetLangkah"] != null) {
      targetLangkah = event["targetLangkah"];
      paksaUpdateNotifikasiAndroid();
    }
  });

  // ==========================================
  // INTERVAL REFRESH UTAMA (TIMER WAKTU)
  // ==========================================
  timer = Timer.periodic(const Duration(seconds: 1), (_) {
    Duration durasi = DateTime.now().difference(mulai);

    // Update Notifikasi & Kirim ke UI setiap detik
    paksaUpdateNotifikasiAndroid();

    service.invoke("update", {
      "langkah": langkah,
      "jarak": jarak,
      "kecepatan": kecepatan,
      "durasi": durasi.inSeconds,
    });
  });

  // ==========================================
  // SENSOR PEDOMETER
  // ==========================================
  try {
    stepSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        if (langkahAwal == -1) {
          langkahAwal = event.steps;
        }
        langkah = event.steps - langkahAwal;
        if (langkah < 0) langkah = 0;

        paksaUpdateNotifikasiAndroid();

        if (langkah >= targetLangkah && !alarmTriggered && langkahAwal != -1) {
          alarmTriggered = true;
          BackgroundService.notification.show(
            200,
            "🎉 Target Tercapai!",
            "Hebat! Anda telah memenuhi target $targetLangkah langkah hari ini.",
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'alarm_target_channel',
                'Alarm Target Olahraga',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
              ),
            ),
          );
        }
      },
      onError: (error) => print("PEDOMETER ERROR: $error"),
    );
  } catch (e) {
    print("Gagal mengaktifkan Pedometer: $e");
  }

  // ==========================================
  // SENSOR GPS
  // ==========================================
  try {
  gpsSubscription = Geolocator.getPositionStream(
    locationSettings: AndroidSettings( // <-- Hapus kata 'const' di sini
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
      intervalDuration: const Duration(seconds: 2), // 'const' hanya dipasang di Duration jika diperlukan
    ),
  ).listen(
    (Position position) {
      if (posisiSebelumnya != null) {
        // Hitung jarak dalam meter, lalu ubah ke kilometer
        double d = Geolocator.distanceBetween(
          posisiSebelumnya!.latitude,
          posisiSebelumnya!.longitude,
          position.latitude,
          position.longitude,
        );
        jarak += (d / 1000.0);

        // Kecepatan dari GPS (m/s) diubah ke km/h
        kecepatan = position.speed * 3.6;
      }
      posisiSebelumnya = position;
      paksaUpdateNotifikasiAndroid();
    },
    onError: (e) => print("GPS ERROR: $e"),
  );
} catch (e) {
  print("Gagal mengaktifkan GPS: $e");
}

  // STOP SERVICE
  service.on("stop").listen((event) {
    timer?.cancel();
    stepSubscription?.cancel();
    gpsSubscription?.cancel();
    service.stopSelf();
  });
}