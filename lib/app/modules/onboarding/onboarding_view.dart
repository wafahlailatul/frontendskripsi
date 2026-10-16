import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kesehatan_jantung/app/modules/landing_page/views/landing_page_view.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnim;
  late Animation<double> _floatAnim;

  final List<_OBPage> _pages = const [
    _OBPage(
      primaryColor: Color(0xFFEF4444),
      secondaryColor: Color(0xFFFF6B6B),
      bgColor: Color(0xFFFFF5F5),
      accentColor: Color(0xFFFFECEC),
      icon: Icons.favorite_rounded,
      illustration: _IllustrationType.heart,
      badge: "Tentang Aplikasi",
      title: "Selamat Datang\ndi HEARTIFY",
      desc:
          "HEARTIFY hadir untuk membantu Anda memahami kondisi kesehatan jantung berdasarkan pola gaya hidup sehari-hari. "
          "Penyakit jantung sering tidak bergejala di awal — deteksi dini adalah langkah terpenting untuk mencegahnya.",
      features: [
        "Gratis & mudah digunakan siapa saja",
        "Data Anda aman & tersimpan pribadi",
        "Dirancang berbasis penelitian kesehatan",
      ],
    ),
    _OBPage(
      primaryColor: Color(0xFF3B82F6),
      secondaryColor: Color(0xFF6366F1),
      bgColor: Color(0xFFF0F5FF),
      accentColor: Color(0xFFEFF6FF),
      icon: Icons.analytics_rounded,
      illustration: _IllustrationType.analysis,
      badge: "Fitur Analisis",
      title: "Hitung Skor Risiko\nJantung Anda",
      desc:
          "Isi 9 faktor gaya hidup — termasuk kebiasaan merokok, pola makan, aktivitas fisik, kualitas tidur, dan tingkat stres — "
          "lalu sistem akan menghitung skor risiko jantung Anda secara otomatis beserta kategori risiko (Rendah / Sedang / Tinggi).",
      features: [
        "9 faktor risiko dianalisis secara menyeluruh",
        "Skor 0–300 dengan kategori risiko jelas",
        "Riwayat analisis tersimpan untuk dipantau",
      ],
    ),
    _OBPage(
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFF059669),
      bgColor: Color(0xFFF0FDF4),
      accentColor: Color(0xFFECFDF5),
      icon: Icons.shield_rounded,
      illustration: _IllustrationType.prevention,
      badge: "Fitur Pencegahan",
      title: "Rekomendasi Nyata\nSesuai Kondisi Anda",
      desc:
          "Setiap hasil analisis dilengkapi saran pencegahan yang spesifik per faktor risiko. "
          "Rekomendasi olahraga juga disesuaikan dengan usia, BMI, dan tingkat aktivitas Anda — bukan saran umum yang sama untuk semua orang.",
      features: [
        "Saran pencegahan khusus tiap faktor risiko",
        "Target durasi & langkah olahraga per minggu",
        "Jenis olahraga disesuaikan usia & BMI",
      ],
    ),
    _OBPage(
      primaryColor: Color(0xFF8B5CF6),
      secondaryColor: Color(0xFFA855F7),
      bgColor: Color(0xFFF5F3FF),
      accentColor: Color(0xFFFAF5FF),
      icon: Icons.notifications_active_rounded,
      illustration: _IllustrationType.reminder,
      badge: "Fitur Pendukung",
      title: "Lengkap untuk\nGaya Hidup Sehat",
      desc:
          "Selain analisis, HEARTIFY dilengkapi fitur pendukung: pengingat kesehatan harian, pelacak aktivitas fisik, "
          "manajemen stres (napas & relaksasi), checklist gaya hidup sehat, serta monitoring perkembangan dari waktu ke waktu.",
      features: [
        "Pengingat: 9+ kategori + kustom bebas",
        "Kelola stres: latihan napas & relaksasi",
        "Tracking aktivitas & progress harian",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LandingPageView(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: page.bgColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: page.bgColor,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo / brand
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: page.primaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: page.primaryColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "HEARTIFY",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: page.primaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    // Skip
                    TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: page.primaryColor.withOpacity(0.6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: page.primaryColor.withOpacity(0.3)),
                        ),
                      ),
                      child: const Text(
                        "Lewati",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              // ── PageView ──
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => _PageContent(
                    page: _pages[i],
                    pulseAnim: _pulseAnim,
                    floatAnim: _floatAnim,
                  ),
                ),
              ),

              // ── Bottom section ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final isActive = _currentPage == i;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? page.primaryColor
                                : page.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 28),

                    // Navigation buttons
                    Row(
                      children: [
                        // Back button (muncul setelah slide 1)
                        if (_currentPage > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: page.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              onPressed: () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              ),
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: page.primaryColor,
                              ),
                            ),
                          ),

                        // Next / Mulai button
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [page.primaryColor, page.secondaryColor],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: page.primaryColor.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentPage < _pages.length - 1
                                        ? "Selanjutnya"
                                        : "Mulai Sekarang",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _currentPage < _pages.length - 1
                                        ? Icons.arrow_forward_rounded
                                        : Icons.rocket_launch_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
}

// ─────────────────────────────────────────────────────
// Konten tiap slide
// ─────────────────────────────────────────────────────
class _PageContent extends StatelessWidget {
  final _OBPage page;
  final Animation<double> pulseAnim;
  final Animation<double> floatAnim;

  const _PageContent({
    required this.page,
    required this.pulseAnim,
    required this.floatAnim,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // ── Ilustrasi ──
          AnimatedBuilder(
            animation: Listenable.merge([pulseAnim, floatAnim]),
            builder: (_, __) => Transform.translate(
              offset: Offset(0, floatAnim.value),
              child: Transform.scale(
                scale: pulseAnim.value,
                child: _Illustration(type: page.illustration, color: page.primaryColor),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: page.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: page.primaryColor.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(page.icon, size: 14, color: page.primaryColor),
                const SizedBox(width: 6),
                Text(
                  page.badge,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: page.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Judul ──
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              height: 1.2,
            ),
          ),

          const SizedBox(height: 14),

          // ── Deskripsi ──
          Text(
            page.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.65,
            ),
          ),

          const SizedBox(height: 24),

          // ── Feature chips (DIPERBAIKI DENGAN EXPANDED) ──
          ...page.features.map((f) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: page.primaryColor.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: page.primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: page.primaryColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Custom Illustration (Flutter Canvas, tanpa gambar)
// ─────────────────────────────────────────────────────
enum _IllustrationType { heart, analysis, prevention, reminder }

class _Illustration extends StatelessWidget {
  final _IllustrationType type;
  final Color color;
  const _Illustration({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran latar belakang
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [color.withOpacity(0.25), color.withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
            ),
          ),
          // Icon utama
          Icon(_getIcon(), size: 72, color: color),

          // Floating icon kecil di sekitar
          ..._buildFloatingIcons(),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case _IllustrationType.heart:
        return Icons.favorite_rounded;
      case _IllustrationType.analysis:
        return Icons.analytics_rounded;
      case _IllustrationType.prevention:
        return Icons.shield_rounded;
      case _IllustrationType.reminder:
        return Icons.alarm_rounded;
    }
  }

  List<Widget> _buildFloatingIcons() {
    final positions = <Map<String, dynamic>>[
      {'icon': _getSecondaryIcon(0), 'top': 10.0, 'left': 30.0, 'size': 22.0},
      {'icon': _getSecondaryIcon(1), 'top': 10.0, 'right': 30.0, 'size': 18.0},
      {'icon': _getSecondaryIcon(2), 'bottom': 20.0, 'left': 20.0, 'size': 20.0},
      {'icon': _getSecondaryIcon(3), 'bottom': 20.0, 'right': 20.0, 'size': 22.0},
    ];

    return positions.map((p) {
      return Positioned(
        top: p['top'] as double?,
        left: p['left'] as double?,
        right: p['right'] as double?,
        bottom: p['bottom'] as double?,
        child: Container(
          width: (p['size'] as double) + 16,
          height: (p['size'] as double) + 16,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            p['icon'] as IconData,
            size: p['size'] as double,
            color: color,
          ),
        ),
      );
    }).toList();
  }

  IconData _getSecondaryIcon(int index) {
    final Map<_IllustrationType, List<IconData>> icons = {
      _IllustrationType.heart: [
        Icons.monitor_heart_rounded,
        Icons.favorite_border_rounded,
        Icons.bloodtype_rounded,
        Icons.health_and_safety_rounded,
      ],
      _IllustrationType.analysis: [
        Icons.bar_chart_rounded,
        Icons.psychology_rounded,
        Icons.assignment_rounded,
        Icons.trending_up_rounded,
      ],
      _IllustrationType.prevention: [
        Icons.directions_run_rounded,
        Icons.restaurant_rounded,
        Icons.bedtime_rounded,
        Icons.self_improvement_rounded,
      ],
      _IllustrationType.reminder: [
        Icons.medication_rounded,
        Icons.water_drop_rounded,
        Icons.local_hospital_rounded,
        Icons.fitness_center_rounded,
      ],
    };
    return icons[type]![index];
  }
}

// ─────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────
class _OBPage {
  final Color primaryColor;
  final Color secondaryColor;
  final Color bgColor;
  final Color accentColor;
  final IconData icon;
  final _IllustrationType illustration;
  final String badge;
  final String title;
  final String desc;
  final List<String> features;

  const _OBPage({
    required this.primaryColor,
    required this.secondaryColor,
    required this.bgColor,
    required this.accentColor,
    required this.icon,
    required this.illustration,
    required this.badge,
    required this.title,
    required this.desc,
    required this.features,
  });
}