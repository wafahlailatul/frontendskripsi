import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart';

class ProgressChartView
    extends StatefulWidget {
  const ProgressChartView({
    super.key,
  });

  @override
  State<ProgressChartView>
      createState() =>
          _ProgressChartViewState();
}

class _ProgressChartViewState
    extends State<
        ProgressChartView> {
  List histories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    getHistory();
  }

  Future<void> getHistory() async {
  final result = await ApiService.getAnalysisHistory();

  debugPrint(result.toString());

  if (result["status"] == "success") {
    setState(() {
      histories = result["data"];
      loading = false;
    });
  } else {
    setState(() {
      loading = false;
    });
  }
}

  Color getColor(
    String category,
  ) {
    if (category ==
        "Risiko Tinggi") {
      return Colors.red;
    }

    if (category ==
        "Risiko Sedang") {
      return Colors.orange;
    }

    return Colors.green;
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Riwayat Analisis",
        ),
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : histories.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada riwayat analisis",
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets
                          .all(15),
                  itemCount:
                      histories.length,
                  itemBuilder:
                      (context,
                          index) {
                    final item =
                        histories[
                            index];

                    return Card(
                      elevation: 3,
                      margin:
                          const EdgeInsets
                              .only(
                        bottom:
                            15,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child:
                          Padding(
                        padding:
                            const EdgeInsets
                                .all(
                          20,
                        ),
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      getColor(
                                    item["category"],
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    item["category"],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: getColor(
                                        item["category"],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Text(
                              "Umur : ${item["age"]} Tahun",
                            ),

                            Text(
                              "Jenis Kelamin : ${item["gender"]}",
                            ),

                            Text(
                              "BMI : ${item["bmi"]}",
                            ),

                            Text(
                              "Status Merokok : ${item["smoking"]}",
                            ),

                            Text(
                              "Lingkungan Perokok : ${item["smoking_environment"]}",
                            ),

                            Text(
                              "Aktivitas Fisik : ${item["activity"]} menit/minggu",
                            ),

                            Text(
                              "Durasi Tidur : ${item["sleep"]} jam/hari",
                            ),

                            Text(
                              "Tingkat Stres : ${item["stress"]}",
                            ),

                            Text(
                              "Pola Makan : ${item["eating"]}",
                            ),

                            Text(
                              "Skor Risiko : ${item["score"]}",
                            ),
                                                        Text(
                              "Skor Risiko : ${item["score"]}",
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Rekomendasi Olahraga :",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              item["sports_target_steps"]?.toString() ?? "-",
                            ),
                            Text(
                              "Faktor Utama : ${item["top_factor"]}",
                            ),

                            Text(
                              "Tanggal : ${item["created_at"]}",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}