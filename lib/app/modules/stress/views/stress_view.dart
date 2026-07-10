import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/modules/stress/views/breathing_view.dart';
import 'package:kesehatan_jantung/app/modules/stress/views/relaxation_view.dart';


class StressView extends StatelessWidget {
  const StressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Stres"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const BreathingView(),
                  ),
                );
              },
              child: cardMenu(
                icon: "🫁",
                title: "Latihan Pernapasan",
                subtitle:
                    "Atur napas untuk menenangkan pikiran",
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const RelaxationView(),
                  ),
                );
              },
              child: cardMenu(
                icon: "🎵",
                title: "Relaksasi Singkat",
                subtitle:
                    "Meditasi dan suara relaksasi",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardMenu({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [

          Text(
            icon,
            style:
                const TextStyle(fontSize: 45),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
          )
        ],
      ),
    );
  }
}