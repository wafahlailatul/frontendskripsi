import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inisialisasi Sistem Notifikasi
  static Future<void> init() async {
    try {
      tz.initializeTimeZones();
      
      // Mengunci seluruh sistem alarm aplikasi ke Zona Waktu Asia/Jakarta (WIB)
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print("Notifikasi diklik: ${response.payload}");
        },
      );

      // Meminta izin notifikasi (Android 13+)
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Meminta izin alarm presisi (Android 12+)
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
          
      print("Reminder Service Sukses Diaktifkan!");
    } catch (e) {
      print("Gagal init Notifikasi: $e");
    }
  }

  // Fungsi Mendaftarkan Jadwal Alarm Harian
  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'heartify_alarm_channel_v4', // Naikkan versi channel agar Android memperbarui konfigurasinya
        'Alarm Pengingat Jantung',
        channelDescription: 'Channel khusus alarm kontinu minum obat',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: null, // Menggunakan Ringtone Bawaan HP
        audioAttributesUsage: AudioAttributesUsage.alarm,
        category: AndroidNotificationCategory.alarm,
        
        // ========================================================
        // KUNCI BARU: Memaksa Pop-Up Alarm Langsung Tembus ke Layar
        // ========================================================
        ticker: 'ticker',
        fullScreenIntent: true, // Membuat notifikasi langsung menyembul (heads-up) atau membuka layar kunci
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      // Ambil kalkulasi tanggal dan jam target secara akurat
      final tz.TZDateTime scheduledTime = _nextInstanceOfTime(hour, minute);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Menjamin menyala walau HP tertidur
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Dipicu berulang setiap hari pada jam ini
      );
      print("Alarm Berhasil Didaftarkan untuk Jam: $hour:$minute");
    } catch (e) {
      print("Gagal set alarm OS: $e");
    }
  }

  // FUNGSI PEMBANTU (Kalkulasi Waktu Target)
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.Location jakartaLocation = tz.getLocation('Asia/Jakarta');
    final tz.TZDateTime now = tz.TZDateTime.now(jakartaLocation);
    
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(jakartaLocation, now.year, now.month, now.day, hour, minute);
    
    // Jika jam yang disetel sudah lewat dari jam sekarang, jadwalkan untuk besok hari
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Membatalkan alarm tertentu
  static Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}