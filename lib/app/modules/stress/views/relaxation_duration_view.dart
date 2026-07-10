import 'package:flutter/material.dart';
import 'relaxation_session_view.dart';

class RelaxationDurationView extends StatelessWidget {
  final String audio;

  const RelaxationDurationView({
    super.key,
    required this.audio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Durasi Relaksasi"),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xffF4F7FC),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 30),

            const Icon(
              Icons.spa,
              size: 100,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            const Text(
              "Pilih Durasi Relaksasi",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 50),

            durasiButton(
              context,
              1,
            ),

            const SizedBox(height: 20),

            durasiButton(
              context,
              3,
            ),

            const SizedBox(height: 20),

            durasiButton(
              context,
              5,
            ),
          ],
        ),
      ),
    );
  }

  Widget durasiButton(
    BuildContext context,
    int menit,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.timer),
        label: Text(
          "$menit Menit",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RelaxationSessionView(
                audio: audio,
                minute: menit,
              ),
            ),
          );
        },
      ),
    );
  }
}