import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kesehatan_jantung/app/modules/Analysis/views/analysis_view.dart';
import 'package:kesehatan_jantung/app/modules/HealthyLifestyle/views/healthy_lifestyle_view.dart';
import 'package:kesehatan_jantung/app/modules/ProgressChart/views/progress_chart_view.dart';
import 'package:kesehatan_jantung/app/modules/aktivitas/views/aktivitas_view.dart';
import 'package:kesehatan_jantung/app/modules/ble_scan/views/ble_scan_view.dart';
import 'package:kesehatan_jantung/app/modules/heartmonitor/views/heartmonitor_view.dart';
import 'package:kesehatan_jantung/app/modules/notifikasi/views/notifikasi_view.dart';
import 'package:kesehatan_jantung/app/modules/profil/views/profil_view.dart';
import 'package:kesehatan_jantung/app/modules/progress_aktifitas/views/progress_aktifitas_view.dart';
import 'package:kesehatan_jantung/app/modules/stress/views/stress_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Latar belakang Slate modern, tidak silau
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER UTAMA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hellooo, Selamat Datang",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Jaga kesehatan jantungmu setiap hari",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  /// ICON PROFIL MINIMALIS
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Get.to(() => const ProfilView()),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF2563EB), // Royal Blue Accent
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// BANNER INFORMASI DATA DIRI (Elegant Clean Alert)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Soft Blue Background alternatif amber
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Get.to(() => const ProfilView()),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF2563EB),
                            size: 22,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Lengkapi data diri pada profil untuk mendapatkan hasil analisis kesehatan yang optimal.",
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              /// JUDUL MENU UTAMA
              const Text(
                "Menu Pencegahan Jantung",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 16),

              /// GRID MENU UTAMA (Layout 2 Kolom Seimbang)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.05, // Rasio kotak pas, tidak terlalu tinggi
                children: [
                  featureCard(
                    "Assessment Risiko",
                    "Analisis risiko jantung",
                    Icons.favorite_border_rounded,
                    const Color(0xFFFEF2F2),
                    const Color(0xFFEF4444),
                    () => Get.to(() => const AnalysisView()),
                  ),
                  featureCard(
                    "Riwayat Analisis",
                    "Pantau perkembangan",
                    Icons.history_edu_rounded,
                    const Color(0xFFECFDF5),
                    const Color(0xFF10B981),
                    () => Get.to(() => const ProgressChartView()),
                  ),

                  featureCard(
                    "Olahraga",
                    "Saran aktivitas fisik",
                    Icons.directions_run_rounded,
                    const Color(0xFFF5F3FF),
                    const Color(0xFF8B5CF6),
                    () => Get.to(() => const AktivitasView()),
                  ),
                  featureCard(
                    "Progress Aktifitas",
                    "Catatan aktivitas harian",
                    Icons.route_rounded,
                    const Color(0xFFF0FDF4),
                    const Color(0xFF22C55E),
                    () => Get.to(() => const ProgressAktifitasView()),
                  ),
                  
                  featureCard(
                    "Manajemen Stres",
                    "Kelola tingkat stres",
                    Icons.self_improvement_rounded,
                    const Color(0xFFF0FDFA),
                    const Color(0xFF14B8A6),
                    () => Get.to(() => const StressView()),
                  ),
                  featureCard(
                    "Pengingat",
                    "Notifikasi kesehatan",
                    Icons.notifications_active_outlined,
                    const Color(0xFFFFF7ED),
                    const Color(0xFFF97316),
                    () => Get.to(() => const NotifikasiView()),
                  ),
                  
                  // featureCard(
                  //   "Smartband",
                  //   "Integrasi perangkat",
                  //   Icons.watch_rounded,
                  //   const Color(0xFFFFF1F2),
                  //   const Color(0xFFF43F5E),
                  //   () => Get.to(() => const HeartmonitorView()),
                  // ),
                  // featureCard(
                  //   "Scan BLE",
                  //   "Hubungkan Smartband",
                  //   Icons.bluetooth_searching_rounded,
                  //   const Color(0xFFEFF6FF),
                  //   const Color(0xFF3B82F6),
                  //   () => Get.to(() => const BleScanView()),
                  // ),
                ],
              ),

              const SizedBox(height: 28),

              /// TIPS SECTION
              const Text(
                "Tips Hari Ini",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 12),

              /// TIPS CARD FLAT MODERN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        color: Color(0xFFD97706),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        "Kurangi konsumsi minuman manis untuk membantu menjaga kesehatan jantung harian.",
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// FEATURE CARD DESIGN (Flat Modern Glassmorphism Look)
  Widget featureCard(
    String title,
    String subtitle,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// SUMMARY CARD METHOD (Dipertahankan kosong agar aman dari error sisa dependensi)
  Widget summaryCard(IconData icon, String title, String value) {
    return const SizedBox.shrink();
  }
}