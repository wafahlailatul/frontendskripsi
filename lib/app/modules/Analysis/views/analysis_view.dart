import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart';

class AnalysisView extends StatefulWidget {
  const AnalysisView({super.key});

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  final aktivitasController = TextEditingController();
  final tidurController = TextEditingController();

  String smoking = "Tidak Merokok";
 String stressLevel = "Rendah";
String stressDescription =
    "Pilih tingkat stres sesuai dengan kondisi yang Anda rasakan.";
  String eatingPattern = "Sehat";
  String eatingDescription =
    "Pilih kategori yang paling sesuai dengan kebiasaan makan Anda sehari-hari.";
  String smokingEnvironment = "Tidak";

  int age = 0;
  String gender = "-";
  double bmi = 0;
  String bmiStatus = "--";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final result = await ApiService.getProfile();
      print(result);

      if (result["status"] == "success") {
        final data = result["data"];

        setState(() {
          age = data["age"] ?? 0;
          gender = data["gender"] ?? "-";
          bmi = double.tryParse(data["bmi"].toString()) ?? 0;
          bmiStatus = data["bmi_status"] ?? "--";
        });
      }
    } catch (e) {
      print("ERROR PROFILE : $e");
    }
  }

Color getStressColor(String level) {
  switch (level) {
    case "Rendah":
      return Colors.green;
    case "Sedang":
      return Colors.orange;
    case "Tinggi":
      return Colors.red;
    default:
      return Colors.blue;
  }
}

Color getEatingColor(String value) {
  switch (value) {
    case "Sehat":
      return Colors.green;
    case "Cukup Sehat":
      return Colors.orange;
    case "Tidak Sehat":
      return Colors.red;
    default:
      return Colors.blue;
  }
}
  @override
  void dispose() {
    aktivitasController.dispose();
    tidurController.dispose();
    super.dispose();
  }

  Map<String, dynamic> calculateRiskDetail({
    required int age,
    required double bmi,
    required String gender,
    required String smoking,
    required int activity,
    required int sleep,
    required String stress,
    required String eating,
    required String smokingEnvironment,
  }) {
    int score = 0;
    List<String> reasons = [];
    List<String> suggestions = [];
    Map<String, int> factorWeight = {};

    // 1. UMUR
    if (age >= 45) {
      score += 2;
      factorWeight["Umur"] = 2;
      reasons.add("Usia di atas 45 tahun meningkatkan risiko penyakit jantung.");
    } else if (age >= 35) {
      score += 1;
      factorWeight["Umur"] = 1;
    }

    // 2. GENDER
    if (gender == "Laki-laki") {
      score += 1;
      factorWeight["Gender"] = 1;
      reasons.add("Laki-laki memiliki risiko lebih tinggi dibanding perempuan pada usia muda.");
    }

    // 3. BMI
    if (bmi >= 30) {
      score += 3;
      factorWeight["BMI"] = 3;
      reasons.add("Obesitas meningkatkan beban kerja jantung.");
      suggestions.add("Turunkan berat badan secara bertahap.");
    } else if (bmi >= 25) {
      score += 2;
      factorWeight["BMI"] = 2;
      reasons.add("Kelebihan berat badan meningkatkan risiko penyakit jantung.");
    }

    // 4. MEROKOK
    if (smoking == "Perokok Aktif") {
      score += 3;
      factorWeight["Merokok"] = 3;
      reasons.add("Merokok merusak pembuluh darah dan meningkatkan tekanan darah.");
      suggestions.add("Segera berhenti merokok.");
    } else if (smoking == "Perokok Pasif") {
      score += 2;
      factorWeight["Merokok"] = 2;
      reasons.add("Paparan asap rokok tetap meningkatkan risiko penyakit jantung.");
    }

    // 5. LINGKUNGAN PEROKOK
    if (smokingEnvironment == "Ya") {
      score += 2;
      factorWeight["Lingkungan"] = 2;
      reasons.add("Sering berada di lingkungan perokok meningkatkan risiko akibat paparan asap rokok.");
      suggestions.add("Usahakan berada di area bebas rokok.");
    }

    // 6. AKTIVITAS
    if (activity < 60) {
      score += 2;
      factorWeight["Aktivitas"] = 2;
      reasons.add("Aktivitas fisik masih sangat kurang.");
    } else if (activity < 150) {
      score += 1;
      factorWeight["Aktivitas"] = 1;
    }

    // 7. TIDUR
    if (sleep < 6 || sleep > 9) {
      score += 2;
      factorWeight["Tidur"] = 2;
      reasons.add("Durasi tidur tidak ideal.");
      suggestions.add("Usahakan tidur 7-8 jam per hari.");
    }

    // 8. STRES
    // 8. STRES
if (stress == "Tinggi") {

  score += 2;
  factorWeight["Stres"] = 2;

  reasons.add(
    "Stres tinggi dapat meningkatkan tekanan darah dan memengaruhi kesehatan jantung."
  );

  suggestions.add(
    "Lakukan relaksasi, olahraga ringan, dan perbaiki kualitas tidur."
  );

} else if (stress == "Sedang") {

  score += 1;
  factorWeight["Stres"] = 1;

  reasons.add(
    "Stres sedang mulai memengaruhi kondisi tubuh dan kebiasaan sehari-hari."
  );

  suggestions.add(
    "Kelola stres dengan istirahat cukup dan aktivitas yang menyenangkan."
  );

}

    // 9. MAKAN
    if (eating == "Tidak Sehat") {
      score += 2;
      factorWeight["Pola Makan"] = 2;
      reasons.add("Pola makan tidak sehat meningkatkan risiko kolesterol dan hipertensi.");
      suggestions.add("Kurangi makanan tinggi garam dan lemak.");
    } else if (eating == "Cukup Sehat") {
      score += 1;
      factorWeight["Pola Makan"] = 1;
    }

    String category = score >= 12 ? "Risiko Tinggi" : score >= 6 ? "Risiko Sedang" : "Risiko Rendah";
    String topFactor = "-";
    int max = 0;
    factorWeight.forEach((key, value) {
      if (value > max) {
        max = value;
        topFactor = key;
      }
    });

    // ================= LOGIKA REKOMENDASI OLAHRAGA DINAMIS =================
    int sportsDuration = 0;
    int sportsTargetSteps = 7000; 
    String sportsRecommendation = "Pertahankan aktivitas fisik aktif Anda saat ini minimal 150 menit/minggu.";

    if (activity < 60) {
      if (age < 35) {
        if (bmi < 25) {
          sportsDuration = 150; sportsTargetSteps = 9000;
          sportsRecommendation = "Rekomendasi olahraga: Joging selama 150 menit/minggu (Bisa dibagi menjadi 3 sesi @50 menit).";
        } else {
          sportsDuration = 180; sportsTargetSteps = 8000;
          sportsRecommendation = "Rekomendasi olahraga: Joging intensitas rendah selama 180 menit/minggu (Bisa dibagi menjadi 4 sesi @45 menit) untuk optimalisasi pembakaran lemak.";
        }
      } 
      else if (age >= 35 && age < 45) {
        if (bmi < 25) {
          sportsDuration = 120; sportsTargetSteps = 7500;
          sportsRecommendation = "Rekomendasi olahraga: Joging selama 120 menit/minggu (Bisa dibagi menjadi 3 sesi @40 menit) untuk memelihara performa miokardium.";
        } else {
          sportsDuration = 150; sportsTargetSteps = 6500;
          sportsRecommendation = "Rekomendasi olahraga: Joging selama 150 menit/minggu (Bisa dibagi menjadi 5 sesi pendek @30 menit) guna menghindari stres berlebih pada persendian kaki.";
        }
      } 
      else { 
        if (bmi < 25) {
          sportsDuration = 90; sportsTargetSteps = 5500;
          sportsRecommendation = "Rekomendasi olahraga: Joging ringan diselingi jalan cepat selama 90 menit/minggu (Bisa dibagi menjadi 3 sesi @30 menit).";
        } else {
          sportsDuration = 75; sportsTargetSteps = 4500;
          sportsRecommendation = "Rekomendasi olahraga: Joging sangat ringan atau jalan santai selama 75 menit/minggu (Bisa dibagi menjadi 3 sesi @25 menit) untuk keamanan sirkulasi darah kardiovaskular.";
        }
      }
    }

    return {
      "score": score,
      "category": category,
      "reasons": reasons,
      "suggestions": suggestions,
      "topFactor": topFactor,
      "sports_duration": sportsDuration,
      "sports_target_steps": sportsTargetSteps,
      "sports_recommendation": sportsRecommendation,
    };
  }
String getStressDescription(String level) {

  if(level == "Rendah"){
    return "Masih mampu mengendalikan tekanan sehari-hari, "
        "tidak sering merasa kewalahan, dan aktivitas masih berjalan normal.";
  }

  else if(level == "Sedang"){
    return "Mulai merasa terbebani oleh masalah, terkadang sulit fokus, "
        "dan tekanan mulai memengaruhi aktivitas.";
  }

  else{
    return "Sering merasa sulit mengendalikan masalah, merasa kewalahan, "
        "mengalami gangguan tidur, dan tekanan mulai memengaruhi kondisi tubuh.";
  }

}

String getEatingDescription(String value) {

  if (value == "Sehat") {
    return "Mengonsumsi sayur dan buah setiap hari, membatasi makanan cepat saji, makanan tinggi garam, makanan berlemak, serta minuman manis.";
  }

  else if (value == "Cukup Sehat") {
    return "Masih cukup sering mengonsumsi makanan bergizi, namun sesekali mengonsumsi makanan cepat saji, makanan tinggi garam, makanan berlemak, atau minuman manis.";
  }

  else {
    return "Jarang mengonsumsi sayur dan buah, serta sering mengonsumsi makanan cepat saji, makanan tinggi garam, makanan berlemak, makanan tinggi gula, atau minuman manis.";
  }

}
  // ================= UI NEW GENERATION =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B), 
        centerTitle: true,
        title: const Text(
          "Analisis Risiko Jantung",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BMI Card Gradient Modern
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D9488), Color(0xFF10B981)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bmi.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "BMI: $bmiStatus",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Row Info Umur & Gender
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.cake_outlined, color: Color(0xFF0D9488), size: 28),
                        const SizedBox(height: 8),
                        Text(
                          "$age Tahun",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 2),
                        const Text("Umur", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          gender == "Laki-laki" ? Icons.male_rounded : Icons.female_rounded,
                          color: gender == "Laki-laki" ? Colors.blue : Colors.pink,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gender,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 2),
                        const Text("Jenis Kelamin", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info Notice Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade200.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.amber.shade800, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Umur, jenis kelamin, dan BMI diambil otomatis dari profil Anda.",
                      style: TextStyle(color: Colors.amber.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Form Section Title
            const Text(
              "Gaya Hidup & Kebiasaan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),

            // INPUTS SECTION
            DropdownButtonFormField<String>(
              value: smoking,
              decoration: InputDecoration(
                labelText: "Status Merokok",
                prefixIcon: const Icon(Icons.smoking_rooms_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              items: const [
                DropdownMenuItem(value: "Tidak Merokok", child: Text("Tidak Merokok")),
                DropdownMenuItem(value: "Perokok Pasif", child: Text("Perokok Pasif")),
                DropdownMenuItem(value: "Perokok Aktif", child: Text("Perokok Aktif")),
              ],
              onChanged: (v) => setState(() => smoking = v!),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: smokingEnvironment,
              decoration: InputDecoration(
                labelText: "Sering di lingkungan perokok?",
                prefixIcon: const Icon(Icons.cloud_queue_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              items: const [
                DropdownMenuItem(value: "Tidak", child: Text("Tidak")),
                DropdownMenuItem(value: "Ya", child: Text("Ya")),
              ],
              onChanged: (value) => setState(() => smokingEnvironment = value!),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: aktivitasController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Aktivitas (menit/minggu)",
                hintText: "Contoh: 150",
                prefixIcon: const Icon(Icons.directions_run_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: tidurController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Tidur (jam/hari)",
                hintText: "Contoh: 7",
                prefixIcon: const Icon(Icons.bedtime_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: stressLevel,
              decoration: InputDecoration(
                labelText: "Tingkat Stres",
                prefixIcon: const Icon(Icons.psychology_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              items: const [
                DropdownMenuItem(value: "Rendah", child: Text("Rendah")),
                DropdownMenuItem(value: "Sedang", child: Text("Sedang")),
                DropdownMenuItem(value: "Tinggi", child: Text("Tinggi")),
              ],
              onChanged: (v) {

              setState(() {

                stressLevel = v!;

                stressDescription = 
                    getStressDescription(v);

              });

              },
            ),
            const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: getStressColor(stressLevel).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: getStressColor(stressLevel),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.psychology,
                      color: getStressColor(stressLevel),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        stressDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: getStressColor(stressLevel),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: eatingPattern,
              decoration: InputDecoration(
                labelText: "Pola Makan",
                prefixIcon: const Icon(Icons.restaurant_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Sehat",
                  child: Text("Sehat"),
                ),
                DropdownMenuItem(
                  value: "Cukup Sehat",
                  child: Text("Cukup Sehat"),
                ),
                DropdownMenuItem(
                  value: "Tidak Sehat",
                  child: Text("Tidak Sehat"),
                ),
              ],
              onChanged: (v) {

              setState(() {

                eatingPattern = v!;

                eatingDescription =
                    getEatingDescription(v);

              });

            },
            ),
            const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: getEatingColor(eatingPattern).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: getEatingColor(eatingPattern),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.restaurant,
                      color: getEatingColor(eatingPattern),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        eatingDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: getEatingColor(eatingPattern),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // BUTTON ANALISIS GRADIENT + SAVE LENGKAP KE DATABASE
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "Analisis Risiko Sekarang",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () async {
                  if (aktivitasController.text.isEmpty || tidurController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Harap isi semua data terlebih dahulu"),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    return;
                  }

                  int activity = int.tryParse(aktivitasController.text) ?? 0;
                  int sleep = int.tryParse(tidurController.text) ?? 0;

                  final result = calculateRiskDetail(
                    age: age,
                    bmi: bmi,
                    gender: gender,
                    smoking: smoking,
                    smokingEnvironment: smokingEnvironment,
                    activity: activity,
                    sleep: sleep,
                    stress: stressLevel,
                    eating: eatingPattern,
                  );

                  // MASUK KE DATABASE VIA API SERVICE
                  await ApiService.saveAnalysis(
                    age: age,
                    bmi: bmi,
                    gender: gender,
                    smoking: smoking,
                    smokingEnvironment: smokingEnvironment,
                    activity: activity,
                    sleep: sleep,
                    stress: stressLevel,
                    eating: eatingPattern,
                    score: result["score"],
                    category: result["category"],
                    topFactor: result["topFactor"],
                    sportsDuration: result["sports_duration"],       
                    sportsTargetSteps: result["sports_target_steps"], 
                    sportsRecommendation: result["sports_recommendation"], 
                  );

                  // POPUP HASIL DIALOG
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      title: const Row(
                        children: [
                          Icon(Icons.analytics_rounded, color: Color(0xFF0D9488)),
                          SizedBox(width: 10),
                          Text("Hasil Analisis", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text("Skor Risiko: ${result["score"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text("${result["category"]}", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal.shade900)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text("🔥 Faktor Utama:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("${result["topFactor"]}", style: const TextStyle(color: Colors.redAccent)),
                            const SizedBox(height: 12),
                            const Text("⚠️ Penyebab:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text((result["reasons"] as List).join("\n"), style: const TextStyle(fontSize: 13)),
                            
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 12),
                            
                            // OUTPUT TARGET OLAHRAGA DI UI
                            const Text("🏃 Rekomendasi Aktivitas Fisik:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                            const SizedBox(height: 6),
                            Text("• Target Durasi: ${result["sports_duration"]} menit/minggu", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text("• Target Langkah: ${result["sports_target_steps"]} langkah/hari", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text("${result["sports_recommendation"]}", style: const TextStyle(fontSize: 13, color: const Color(0xFF1E293B))),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF0D9488)),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Selesai", style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}