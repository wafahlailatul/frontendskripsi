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

    // 1. Channel khusus tracking (LOW Importance agar update setiap detik TIDAK berbunyi bip terus)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'activity_channel',
      'Aktivitas Fisik',
      description: 'Channel untuk tracking langkah dan rute olahraga',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    // 2. Channel khusus ALARM TARGET TERCAPAI (MAX Importance + Suara Aktif)
    const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
      'alarm_target_channel',
      'Alarm Target Olahraga',
      description: 'Channel khusus untuk alarm saat target olahraga sukses tercapai',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // Daftarkan kedua channel ke sistem Android
    await notification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    await notification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(alarmChannel);

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
        initialNotificationContent: "Menunggu instruksi...",
        notificationChannelId: 'activity_channel',
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  static Future<void> start() async {
    // Meminta izin sensor esensial sebelum service dijalankan
    Map<Permission, PermissionStatus> statuses = await [
      Permission.activityRecognition,
      Permission.locationWhenInUse,
      Permission.locationAlways,
    ].request();

    if (statuses[Permission.activityRecognition]!.isGranted &&
        statuses[Permission.locationWhenInUse]!.isGranted) {
      await service.startService();
    }
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
  int targetLangkah = 7000; // Default jika belum dilempar dari DB
  bool alarmTriggered = false; // Kunci pengunci agar alarm hanya bunyi sekali

  Position? posisiSebelumnya;
  DateTime mulai = DateTime.now();
  Timer? timer;

  StreamSubscription<StepCount>? stepSubscription;
  StreamSubscription<Position>? gpsSubscription;

  // Fungsi internal untuk memaksa Android memperbarui teks notifikasi langsung dari sensor (Background/Layar Mati)
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

  // Menerima input target langkah yang dinamis dari UI Flutter
  service.on("setTarget").listen((event) {
    if (event != null && event["targetLangkah"] != null) {
      targetLangkah = event["targetLangkah"];
    }
  });

  // ==========================================
  // SENSOR PEDOMETER (LANGKAH KAKI)
  // ==========================================
  stepSubscription = Pedometer.stepCountStream.listen(
    (StepCount event) {
      if (langkahAwal == -1) {
        langkahAwal = event.steps;
      }
      langkah = event.steps - langkahAwal;
      if (langkah < 0) langkah = 0;

      // Paksa update teks notifikasi setiap kali melangkah (walau layar mati)
      paksaUpdateNotifikasiAndroid();

      // Logika alarm pemicu ketika target langkah tercapai (Hanya eksekusi sekali)
      if (langkah >= targetLangkah && !alarmTriggered && langkahAwal != -1) {
        alarmTriggered = true; // Langsung kunci status ke TRUE

        BackgroundService.notification.show(
          200, // ID baru khusus alarm target agar tidak menimpa notifikasi utama
          "🎉 Target Tercapai!",
          "Hebat! Anda telah memenuhi target $targetLangkah langkah hari ini.",
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'alarm_target_channel', // Diarahkan ke channel berbunyi kuat
              'Alarm Target Olahraga',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              onlyAlertOnce: true, // Android OS dipaksa mengunci suara agar tidak berulang
            ),
          ),
        );
      }
    },
    onError: (error) => print("PEDOMETER ERROR: $error"),
  );

  // ==========================================
  // SENSOR GPS (JARAK & KECEPATAN)
  // ==========================================
  gpsSubscription = Geolocator.getPositionStream(
    locationSettings: AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1, // Update setiap bergerak 1 meter
      intervalDuration: const Duration(seconds: 2),
      foregroundNotificationConfig: ForegroundNotificationConfig(
        notificationText: "Mencatat rute aktivitas kardio Anda",
        notificationTitle: "GPS Aktif",
      ),
    ),
  ).listen((Position position) {
    if (position.accuracy > 25) return; // Abaikan jika sinyal GPS buruk

    if (posisiSebelumnya != null) {
      double distance = Geolocator.distanceBetween(
        posisiSebelumnya!.latitude,
        posisiSebelumnya!.longitude,
        position.latitude,
        position.longitude,
      );

      if (distance >= 1.0) {
        jarak += distance / 1000; // Konversi ke Kilometer
      }
    }
    posisiSebelumnya = position;
    kecepatan = position.speed * 3.6; // Konversi m/s ke km/jam

    // Paksa update teks notifikasi setiap kali koordinat GPS bergeser (walau layar mati)
    paksaUpdateNotifikasiAndroid();
  });

  // ==========================================
  // INTERVAL REFRESH UI (1 DETIK)
  // ==========================================
  timer = Timer.periodic(const Duration(seconds: 1), (_) {
    Duration durasi = DateTime.now().difference(mulai);

    // Update waktu berkala agar detik terus berjalan mulus di status bar saat layar hidup
    paksaUpdateNotifikasiAndroid();

    // Kirim data terbaru ke UI halaman utama Flutter
    service.invoke("update", {
      "langkah": langkah,
      "jarak": jarak,
      "kecepatan": kecepatan,
      "durasi": durasi.inSeconds,
    });
  });

  // ==========================================
  // AKSI KETIKA TOMBOL SELESAI DITEKAN
  // ==========================================
  service.on("stop").listen((event) {
    timer?.cancel();
    stepSubscription?.cancel();
    gpsSubscription?.cancel();
    service.stopSelf();
  });
}