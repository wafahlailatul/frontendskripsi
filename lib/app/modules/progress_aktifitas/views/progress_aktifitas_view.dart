import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart'; // Sesuaikan path ApiService kamu

class ProgressAktifitasView extends StatefulWidget {
  const ProgressAktifitasView({Key? key}) : super(key: key);

  @override
  _ProgressAktifitasViewState createState() => _ProgressAktifitasViewState();
}

class _ProgressAktifitasViewState extends State<ProgressAktifitasView> {
  List<dynamic> listAktivitas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    muatDataAktivitas();
  }

  Future<void> muatDataAktivitas() async {
    try {
      final result = await ApiService.getAllActivities();
      if (result["status"] == "success" && result["data"] != null) {
        setState(() {
          listAktivitas = result["data"];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Gagal memuat riwayat: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Riwayat Aktivitas Fisik"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : listAktivitas.isEmpty
              ? const Center(child: Text("Belum ada riwayat aktivitas fisik."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listAktivitas.length,
                  itemBuilder: (context, index) {
                    final item = listAktivitas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Baris Atas: Icon Olahraga & Tanggal
                            Row(
                            children: [

                              Icon(
                                Icons.directions_run,
                                color: Colors.teal.shade700,
                                size: 28,
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    const Text(
                                      "Aktivitas Kardio",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    Text(
                                      item["created_at"]?.toString() ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                            const Divider(height: 24),
                            // Baris Bawah: Grid data Langkah, Jarak, Durasi, Kalori
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(Icons.directions_walk, "${item['langkah']}", "Langkah"),
                                _buildStatItem(Icons.map, "${double.parse(item['jarak'].toString()).toStringAsFixed(2)} km", "Jarak"),
                                _buildStatItem(Icons.timer, "${item['durasi']} dtk", "Durasi"),
                                _buildStatItem(Icons.local_fire_department, "${item['kalori']}", "Kcal"),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
      ],
    );
  }
}