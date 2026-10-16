import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

                  // Panggil API (ML Model)
                  final apiResponse = await ApiService.saveAnalysis(
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

                  if (apiResponse["status"] != "success") {
                     String errorMsg = apiResponse["message"] ?? "Gagal menganalisis risiko";
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $errorMsg")));
                     return;
                  }

                  final result = apiResponse["data"];

                  // Siapkan dummy list untuk UI yang bergantung pada rule-based lama
                  result["reasons"] = ["Berdasarkan prediksi model Machine Learning Random Forest."];
                  result["suggestions"] = [result["sportsRecommendation"] ?? "Tetap jaga pola hidup sehat."];
                  
                  // Pastikan field memiliki nama yang sesuai dengan UI
                  result["sports_duration"] = result["sportsDuration"];
                  result["sports_target_steps"] = result["sportsTargetSteps"];
                  result["sports_recommendation"] = result["sportsRecommendation"];

                  // SIMPAN UNTUK SMART REMINDER DI HOME
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('last_analysis_date', DateTime.now().toIso8601String());
                  await prefs.setString('last_risk_category', result["category"]);

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
                            // ── Skor & Kategori ──
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: result["category"] == "Risiko Tinggi"
                                    ? Colors.red.shade50
                                    : result["category"] == "Risiko Sedang"
                                        ? Colors.orange.shade50
                                        : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: result["category"] == "Risiko Tinggi"
                                      ? Colors.red.shade200
                                      : result["category"] == "Risiko Sedang"
                                          ? Colors.orange.shade200
                                          : Colors.green.shade200,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Skor Risiko: ${result["score"]}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    "${result["category"]}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: result["category"] == "Risiko Tinggi"
                                          ? Colors.red.shade700
                                          : result["category"] == "Risiko Sedang"
                                              ? Colors.orange.shade700
                                              : Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // ── Faktor Utama ──
                            const Text("🔥 Faktor Risiko Utama:", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("${result["topFactor"]}", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),

                            // ── Penyebab ──
                            const Text("⚠️ Penyebab Risiko:", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            ...(result["reasons"] as List).map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(r.toString(), style: const TextStyle(fontSize: 13))),
                                ],
                              ),
                            )),

                            // ── Saran Pencegahan (suggestions) ──
                            if ((result["suggestions"] as List).isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              const Text("✅ Langkah Pencegahan:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                              const SizedBox(height: 6),
                              ...(result["suggestions"] as List).map((s) => Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D9488).withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF0D9488).withOpacity(0.2)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF0D9488), size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(s.toString(), style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)))),
                                  ],
                                ),
                              )),
                            ],

                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),

                            // ── Rekomendasi Olahraga ──
                            const Text("🏃 Rekomendasi Aktivitas Fisik:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.timer_outlined, color: Colors.blue, size: 20),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${result["sports_duration"]} mnt",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                                        ),
                                        const Text("per minggu", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.directions_walk_rounded, color: Colors.purple, size: 20),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${result["sports_target_steps"]}",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.purple),
                                        ),
                                        const Text("langkah/hari", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${result["sports_recommendation"]}",
                              style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                            ),
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