import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:kesehatan_jantung/app/modules/Analysis/views/analysis_view.dart';
import 'package:kesehatan_jantung/app/modules/ProgressChart/views/progress_chart_view.dart';
import 'package:kesehatan_jantung/app/modules/aktivitas/views/aktivitas_view.dart';
import 'package:kesehatan_jantung/app/modules/cobaaa/views/cobaaa_view.dart';
import 'package:kesehatan_jantung/app/modules/notifikasi/views/notifikasi_view.dart';
import 'package:kesehatan_jantung/app/modules/profil/views/profil_view.dart';
import 'package:kesehatan_jantung/app/modules/progress_aktifitas/views/progress_aktifitas_view.dart';
import 'package:kesehatan_jantung/app/modules/stress/views/stress_view.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late TutorialCoachMark tutorialCoachMark;

  final GlobalKey keyProfile = GlobalKey();
  final GlobalKey keyAssessment = GlobalKey();
  final GlobalKey keyRiwayat = GlobalKey();
  final GlobalKey keyOlahraga = GlobalKey();
  final GlobalKey keyProgres = GlobalKey();
  final GlobalKey keyStres = GlobalKey();
  final GlobalKey keyPengingat = GlobalKey();

  RssFeed? _rssFeed;
  bool _isLoadingRss = true;

  // Variabel untuk Smart Reminder
  bool _showReminderBanner = false;
  String _reminderMessage = "";

  @override
  void initState() {
    super.initState();
    _checkTutorial();
    _fetchRssFeed();
    _checkAnalysisReminder();
  }

  Future<void> _checkAnalysisReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString('last_analysis_date');
    final lastCategory = prefs.getString('last_risk_category');

    if (lastDateStr != null && lastCategory != null) {
      final lastDate = DateTime.parse(lastDateStr);
      final now = DateTime.now();
      final difference = now.difference(lastDate).inDays;

      int limitDays = 180; // Default Risiko Rendah: 6 bulan
      if (lastCategory == "Risiko Tinggi") {
        limitDays = 30; // 1 bulan
      } else if (lastCategory == "Risiko Sedang") {
        limitDays = 90; // 3 bulan
      }

      if (difference >= limitDays) {
        if (mounted) {
          setState(() {
            _showReminderBanner = true;
            _reminderMessage = "⚠️ Waktunya Evaluasi Ulang!\nSudah $difference hari sejak analisis terakhir Anda ($lastCategory). Mari cek perkembangan gaya hidup Anda sekarang!";
          });
        }
      }
    }
  }

  Future<void> _fetchRssFeed() async {
    try {
      final response = await http.get(Uri.parse(
          'https://news.google.com/rss/search?q=penyakit+jantung&hl=id&gl=ID&ceid=ID:id'));
      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);
        if (mounted) {
          setState(() {
            _rssFeed = feed;
            _isLoadingRss = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingRss = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingRss = false);
    }
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool tutorialDone = prefs.getBool('home_tutorial_done') ?? false;
    
    if (!tutorialDone) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _showTutorial();
      });
      await prefs.setBool('home_tutorial_done', true);
    }
  }

  void _showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: const Color(0xFF1E3A8A),
      textSkip: "LEWATI",
      paddingFocus: 10,
      opacityShadow: 0.85,
    )..show(context: context);
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "Profil",
        keyTarget: keyProfile,
        alignSkip: Alignment.bottomRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                "Profil & Akun",
                "Kelola data diri, cek alamat email, dan ubah pengaturan profil Anda di sini.",
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Assessment",
        keyTarget: keyAssessment,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                "Hitung Skor Risiko Jantung",
                "Di sini Anda bisa mengisi 9 faktor gaya hidup untuk dianalisis dan mendapatkan rekomendasi pencegahan.",
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Riwayat",
        keyTarget: keyRiwayat,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                "Pantau Progres",
                "Semua hasil analisis akan tersimpan di sini, Anda bisa melihat perkembangan kesehatan jantung Anda.",
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Olahraga",
        keyTarget: keyOlahraga,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialContent(
                "Pelacakan Olahraga",
                "Lacak jumlah langkah kaki dan aktivitas fisik Anda setiap hari untuk mencapai target sehat.",
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Progres Fisik",
        keyTarget: keyProgres,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                "Catatan Progres Fisik",
                "Catat dan pantau perubahan berat badan, tinggi badan, dan BMI Anda secara rutin.",
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Stres Kontrol",
        keyTarget: keyStres,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                "Kelola Stres Anda",
                "Gunakan fitur ini untuk latihan pernapasan, relaksasi, dan memutar suara alam untuk meredakan stres.",
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "Pengingat",
        keyTarget: keyPengingat,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildTutorialContent(
                "Jaga Konsistensi",
                "Gunakan fitur ini untuk mengatur pengingat harian, mulai dari minum air hingga jadwal kontrol dokter.",
              );
            },
          ),
        ],
      ),
    ];
  }

  Widget _buildTutorialContent(String title, String desc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),
        ),
        const SizedBox(height: 10.0),
        Text(
          desc,
          style: const TextStyle(color: Colors.white, fontSize: 14.0, height: 1.4),
        ),
        const SizedBox(height: 16.0),
        const Text(
          "👉 Ketuk layar untuk lanjut",
          style: TextStyle(color: Colors.white70, fontSize: 12.0, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// SMART REMINDER BANNER
              if (_showReminderBanner) ...[
                GestureDetector(
                  onTap: () {
                    Get.to(() => const AnalysisView());
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade300, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade100,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _reminderMessage,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
                      ],
                    ),
                  ),
                ),
              ],

              /// 1. HERO HEADER CARD WITH GRADIENT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Halo, Selamat Datang! 👋",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Pantau dan jaga kesehatan jantungmu setiap hari.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFDBEAFE),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    /// Profil Avatar Button
                    Material(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        key: keyProfile,
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Get.to(() => const ProfilView()),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 2. ELEGANT PROFIL ALERT BANNER
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Get.to(() => const ProfilView()),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Lengkapi data diri di profil untuk hasil analisis yang presisi.",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF334155),
                                height: 1.3,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              /// 3. JUDUL MENU UTAMA
              const Text(
                "Menu Utama",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 14),

              /// 4. GRID MENU FITUR (2 Kolom Modern)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.1,
                children: [
                  _buildFeatureCard(
                    key: keyAssessment,
                    title: "Assessment",
                    subtitle: "Analisis risiko jantung",
                    icon: Icons.favorite_rounded,
                    accentColor: const Color(0xFFEF4444),
                    bgColor: const Color(0xFFFEF2F2),
                    onTap: () => Get.to(() => const AnalysisView()),
                  ),
                  _buildFeatureCard(
                    key: keyRiwayat,
                    title: "Riwayat",
                    subtitle: "Progres & histori",
                    icon: Icons.analytics_rounded,
                    accentColor: const Color(0xFF10B981),
                    bgColor: const Color(0xFFECFDF5),
                    onTap: () => Get.to(() => const ProgressChartView()),
                  ),
                  _buildFeatureCard(
                    key: keyOlahraga,
                    title: "Olahraga",
                    subtitle: "Pelacakan aktivitas",
                    icon: Icons.directions_run_rounded,
                    accentColor: const Color(0xFF8B5CF6),
                    bgColor: const Color(0xFFF5F3FF),
                    onTap: () => Get.to(() => const AktivitasView()),
                  ),
                  _buildFeatureCard(
                    key: keyProgres,
                    title: "Progres Fisik",
                    subtitle: "Catatan harian",
                    icon: Icons.route_rounded,
                    accentColor: const Color(0xFF06B6D4),
                    bgColor: const Color(0xFFECFEFF),
                    onTap: () => Get.to(() => const ProgressAktifitasView()),
                  ),
                  _buildFeatureCard(
                    key: keyStres,
                    title: "Stres Kontrol",
                    subtitle: "Kelola tingkat stres",
                    icon: Icons.self_improvement_rounded,
                    accentColor: const Color(0xFF14B8A6),
                    bgColor: const Color(0xFFF0FDFA),
                    onTap: () => Get.to(() => const StressView()),
                  ),
                //  _buildFeatureCard(
                //     title: "cobaa",
                //     subtitle: "cobaa",
                //     icon: Icons.self_improvement_rounded,
                //     accentColor: const Color(0xFF14B8A6),
                //     bgColor: const Color(0xFFF0FDFA),
                //     onTap: () => Get.to(() => const CobaaaView()),
                //   ),
                  _buildFeatureCard(
                    key: keyPengingat,
                    title: "Pengingat",
                    subtitle: "Notifikasi jadwal",
                    icon: Icons.notifications_active_rounded,
                    accentColor: const Color(0xFFF97316),
                    bgColor: const Color(0xFFFFF7ED),
                    onTap: () => Get.to(() => const NotifikasiView()),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// 5. ARTIKEL KESEHATAN (RSS FEED)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Artikel Kesehatan Terkini",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Icon(Icons.article_rounded, color: Colors.blue.shade400, size: 20),
                ],
              ),
              const SizedBox(height: 14),
              _buildRssSection(),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRssSection() {
    if (_isLoadingRss) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_rssFeed == null || _rssFeed!.items == null || _rssFeed!.items!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: const Center(
          child: Text(
            "Belum ada artikel terbaru.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _rssFeed!.items!.length > 5 ? 5 : _rssFeed!.items!.length,
      itemBuilder: (context, index) {
        final item = _rssFeed!.items![index];
        final titleParts = item.title?.split(" - ") ?? ["Tanpa Judul"];
        final source = titleParts.length > 1 ? titleParts.last : "Google News";
        final cleanTitle = titleParts.length > 1 
            ? titleParts.sublist(0, titleParts.length - 1).join(" - ") 
            : titleParts.first;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                final url = item.link;
                if (url != null) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            cleanTitle,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.blue.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            source,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.pubDate != null 
                              ? item.pubDate.toString().split(" ").take(4).join(" ") 
                              : "Hari ini",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// WIDGET CARD FEATURE REUSABLE
  Widget _buildFeatureCard({
    Key? key,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 22,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}