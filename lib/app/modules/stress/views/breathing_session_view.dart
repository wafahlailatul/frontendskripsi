import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/widgets/breathing_card.dart';
class BreathingSessionView extends StatefulWidget {
  final int minute;

  const BreathingSessionView({
    super.key,
    required this.minute,
  });

  @override
  State<BreathingSessionView> createState() =>
      _BreathingSessionViewState();
}

class _BreathingSessionViewState
    extends State<BreathingSessionView>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  late Timer timer;

  int remainingSeconds = 0;

  String instruction = "Tarik Napas";

  int phase = 0;

  @override
  void initState() {
    super.initState();

    remainingSeconds =
        widget.minute * 60;

    controller = AnimationController(
  vsync: this,
  duration: const Duration(seconds: 4),
  lowerBound: 0.6,
  upperBound: 1,
);

controller.forward();

    startBreathing();

    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {

        if (!mounted) return;

        if (remainingSeconds <= 0) {

          timer.cancel();

          selesai();

          return;
        }

        setState(() {
          remainingSeconds--;
        });
      },
    );
  }

  void startBreathing() {
  Timer.periodic(
    const Duration(seconds: 4),
    (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      phase++;

      setState(() {
        if (phase % 3 == 0) {
          instruction = "Tarik Napas";
          controller.forward();
        } else if (phase % 3 == 1) {
          instruction = "Tahan";
        } else {
          instruction = "Buang Napas";
          controller.reverse();
        }
      });
    },
  );
}

  void selesai() {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "🎉 Selesai",
          ),
          content: Text(
            "Anda telah menyelesaikan latihan pernapasan selama ${widget.minute} menit.",
          ),
          actions: [

            ElevatedButton(
              onPressed: () {

                Navigator.pop(context);

                Navigator.pop(context);

              },
              child: const Text(
                "OK",
              ),
            ),
          ],
        );
      },
    );
  }

  String formatTime() {

    int minute =
        remainingSeconds ~/ 60;

    int second =
        remainingSeconds % 60;

    return
        "${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {

    timer.cancel();

    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF4F7FC),

      appBar: AppBar(
        title:
            const Text("Latihan Pernapasan"),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Text(
  instruction,
  style: const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 40),

BreathingCard(
  animation: controller,
),

const SizedBox(height: 50),

Text(
  formatTime(),
  style: const TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
  ),
),
          ],
        ),
      ),
    );
  }
}