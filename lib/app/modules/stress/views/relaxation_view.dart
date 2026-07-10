import 'package:flutter/material.dart';
import 'relaxation_session_view.dart';

class RelaxationView extends StatelessWidget {
  const RelaxationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relaksasi"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            card(
              context,
              "🌧 Hujan",
              "assets/audio/rain.mp3",
            ),

            card(
              context,
              "🌳 Hutan",
              "assets/audio/forest.mp3",
            ),

            card(
              context,
              "🌊 Ombak",
              "assets/audio/ocean.mp3",
            ),
          ],
        ),
      ),
    );
  }

  Widget card(
    BuildContext context,
    String title,
    String audio,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: const Icon(
          Icons.spa,
          color: Colors.green,
        ),
        title: Text(title),
        subtitle: const Text(
          "1 - 5 menit relaksasi",
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),
        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RelaxationSessionView(
                audio: audio,
                minute: 3,
              ),
            ),
          );
        },
      ),
    );
  }
}