import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart';
import 'package:kesehatan_jantung/app/background/background_service.dart';

class AktivitasView extends StatefulWidget {
  const AktivitasView({super.key});

  @override
  State<AktivitasView> createState() => _AktivitasViewState();
}

class _AktivitasViewState extends State<AktivitasView> {
  int langkah = 0;
  double jarak = 0;
  double kecepatan = 0;
  Duration durasi = Duration.zero;
  bool isTracking = false;
  String statusAktivitas = "Belum Dimulai";

  // Data rekomendasi default (diambil dinamis dari riwayat analisis berkala)
  int targetLangkah = 7000;
  int targetDurasiMenit = 30; 

  @override
  void initState() {
    super.initState();
    loadRekomendasiOlahraga();
    listenBackground();
  }

  Future<void> loadRekomendasiOlahraga() async {
  try {
    // SEKARANG: Memanggil data analisis terakhir dari database, BUKAN profil lagi!
    final result = await ApiService.getLastAnalysis(); 
    
    if (result["status"] == "success" && result["data"] != null) {
      final data = result["data"];
      setState(() {
        // Mengambil data real dari kolom database yang baru kita buat kemarin
        targetLangkah = data["sports_target_steps"] ?? 7000;
        
        int totalMinggu = data["sports_duration"] ?? 150;
        // Konversi durasi mingguan ke target menit per hari (dibagi rata 4 atau 5 sesi)
        targetDurasiMenit = totalMinggu > 0 ? (totalMinggu / 4).round() : 30;
      });
    }
  } catch (e) {
    print("Gagal memuat target rekomendasi dari database: $e");
  }
}
  void listenBackground() {
    BackgroundService.service.on("update").listen((event) {
      if (event == null || !mounted) return;

      setState(() {
        langkah = event["langkah"] ?? 0;
        jarak = (event["jarak"] ?? 0).toDouble();
        kecepatan = (event["kecepatan"] ?? 0).toDouble();
        durasi = Duration(seconds: event["durasi"] ?? 0);

        if (kecepatan >= 5.5) {
          statusAktivitas = "Jogging";
        } else if (kecepatan >= 1.2) {
          statusAktivitas = "Berjalan";
        } else {
          statusAktivitas = "Diam";
        }
      });
    });
  }

  Future<void> mulaiAktivitas() async {
    await BackgroundService.start();
    // Mengirim target langkah terbaru ke background thread service
    BackgroundService.service.invoke("setTarget", {"targetLangkah": targetLangkah});
    
    setState(() {
      langkah = 0;
      jarak = 0;
      kecepatan = 0;
      durasi = Duration.zero;
      isTracking = true;
      statusAktivitas = "Mendeteksi...";
    });
  }

  Future<void> selesaiAktivitas() async {
    await BackgroundService.stop();
    setState(() {
      isTracking = false;
      statusAktivitas = "Selesai";
    });
    await saveActivity();
  }

  Future<void> saveActivity() async {
    await ApiService.saveActivity(
      langkah: langkah,
      jarak: jarak,
      durasi: durasi.inSeconds,
      kalori: hitungKalori(),
    );
  }

  double hitungKalori() => langkah * 0.04;

  String formatDurasi() {
    String menit = (durasi.inMinutes % 60).toString().padLeft(2, '0');
    String detik = (durasi.inSeconds % 60).toString().padLeft(2, '0');
    return "$menit:$detik";
  }

  @override
  Widget build(BuildContext context) {
    double progressLangkah = (langkah / targetLangkah).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        title: const Text("Aktivitas Fisik Kardio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Target Info Header Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text("🎯 Target Langkah", style: TextStyle(fontSize: 12, color: Colors.teal)),
                      const SizedBox(height: 4),
                      Text("$targetLangkah Langkah", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F766E))),
                    ],
                  ),
                  Container(width: 1, height: 30, color: Colors.teal.shade200),
                  Column(
                    children: [
                      const Text("⏱ Estimasi Durasi", style: TextStyle(fontSize: 12, color: Colors.teal)),
                      const SizedBox(height: 4),
                      Text("$targetDurasiMenit Menit/Sesi", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F766E))),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Circular Tracker Progress
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progressLangkah,
                    strokeWidth: 16,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "$langkah",
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Status: $statusAktivitas",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 32),

            // Grid Metrik Olahraga
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMetricCard("📍", "Jarak Tempuh", "${jarak.toStringAsFixed(2)} km"),
                _buildMetricCard("⏱", "Durasi Waktu", formatDurasi()),
                _buildMetricCard("⚡", "Kecepatan", "${kecepatan.toStringAsFixed(1)} km/j"),
                _buildMetricCard("🔥", "Kalori Terbakar", "${hitungKalori().toStringAsFixed(1)} kkal"),
              ],
            ),
            const SizedBox(height: 40),

            // Kontrol Pemicu Mulai/Selesai Tombol
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isTracking ? selesaiAktivitas : mulaiAktivitas,
                icon: Icon(isTracking ? Icons.stop_circle_rounded : Icons.play_circle_filled_rounded, color: Colors.white, size: 24),
                label: Text(isTracking ? "Selesai & Simpan Aktivitas" : "Mulai Olahraga", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTracking ? const Color(0xFFEF4444) : const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              isTracking ? "🟢 Sistem merekam langkah di background harian Anda." : "⚪ Tekan Mulai untuk mengaktifkan pelacakan sensor.",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String emoji, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}