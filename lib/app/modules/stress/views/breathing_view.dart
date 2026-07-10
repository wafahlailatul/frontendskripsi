import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/modules/stress/views/breathing_session_view.dart';

class BreathingView extends StatefulWidget {
  const BreathingView({super.key});

  @override
  State<BreathingView> createState() =>
      _BreathingViewState();
}

class _BreathingViewState
    extends State<BreathingView> {

  int selectedMinute = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      appBar: AppBar(
        title: const Text(
          "Latihan Pernapasan",
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const Text(
              "Pilih Durasi",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            durationCard(1),
            const SizedBox(height: 20),

            durationCard(3),
            const SizedBox(height: 20),

            durationCard(5),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BreathingSessionView(
                      minute: selectedMinute,
                    ),
                  ),
                );
              },
                child: const Text(
                  "Mulai",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 240, 112, 112),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget durationCard(int minute) {
    bool selected =
        selectedMinute == minute;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMinute = minute;
        });
      },
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? Colors.blue
              : Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            )
          ],
        ),
        child: Center(
          child: Text(
            "$minute Menit",
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
              color: selected
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}