
import 'package:flutter/material.dart';

class HealthyLifestyleView extends StatefulWidget {
  const HealthyLifestyleView({super.key});

  @override
  State<HealthyLifestyleView> createState() =>
      _HealthyLifestyleViewState();
}

class _HealthyLifestyleViewState
    extends State<HealthyLifestyleView> {

  List<bool> habits = [
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  final List<Map<String, dynamic>> habitData = [
    {
      "title": "Minum Air 2 Liter",
      "icon": Icons.water_drop,
    },
    {
      "title": "Berjalan 5000 Langkah",
      "icon": Icons.directions_walk,
    },
    {
      "title": "Tidur 7-8 Jam",
      "icon": Icons.bedtime,
    },
    {
      "title": "Olahraga 30 Menit",
      "icon": Icons.fitness_center,
    },
    {
      "title": "Konsumsi Buah & Sayur",
      "icon": Icons.restaurant,
    },
    {
      "title": "Tidak Merokok",
      "icon": Icons.health_and_safety,
    },
  ];

  int get completedCount =>
      habits.where((e) => e).length;

  double get progress =>
      completedCount / habits.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F8FF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Habit Tracker",
          style: TextStyle(
            color: Color(0xFF123B6A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(30),

                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8ED0FF),
                    Color(0xFF3A9BFF),
                  ],
                ),
              ),

              child: Column(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 50,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const Text(
                    "Progres Kebiasaan Hari Ini",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20),
                    child:
                        LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor:
                          Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation(
                        Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// STATUS
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                    Icons.check_circle,
                    "$completedCount",
                    "Selesai",
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _infoCard(
                    Icons.local_fire_department,
                    "7",
                    "Streak Hari",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Kebiasaan Sehat Jantung",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF123B6A),
              ),
            ),

            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount:
                  habitData.length,

              itemBuilder:
                  (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .black
                            .withOpacity(
                          0.05,
                        ),
                        blurRadius: 10,
                      ),
                    ],
                  ),

                  child:
                      CheckboxListTile(
                    activeColor:
                        const Color(
                      0xFF3A9BFF,
                    ),

                    secondary: Icon(
                      habitData[index]
                          ["icon"],
                      color:
                          const Color(
                        0xFF3A9BFF,
                      ),
                    ),

                    value:
                        habits[index],

                    title: Text(
                      habitData[index]
                          ["title"],
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight
                                .w600,
                        color: Color(
                          0xFF123B6A,
                        ),
                      ),
                    ),

                    onChanged:
                        (value) {
                      setState(() {
                        habits[index] =
                            value!;
                      });
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            /// TOMBOL PENGINGAT
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Fitur pengingat akan segera tersedia",
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                ),

                label: const Text(
                  "Atur Pengingat",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF3A9BFF,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
    IconData icon,
    String value,
    String title,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color:
                const Color(0xFF3A9BFF),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xFF123B6A),
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

