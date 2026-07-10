import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class RelaxationSessionView extends StatefulWidget {
  final String audio;
  final int minute;

  const RelaxationSessionView({
  super.key,
  required this.audio,
  required this.minute,
});

  @override
  State<RelaxationSessionView> createState() =>
      _RelaxationSessionViewState();
}

class _RelaxationSessionViewState
    extends State<RelaxationSessionView> {

  final player = AudioPlayer();

  Timer? timer;

  late int remainingSeconds;

  Timer? quoteTimer;

  int quoteIndex = 0;

  final List<String> quotes = [
    "Tarik napas perlahan...",
    "Lepaskan pikiran yang mengganggu...",
    "Nikmati suara alam...",
    "Tenangkan tubuh dan pikiran...",
    "Fokus pada napas Anda...",
  ];


  void startQuote() {
  quoteTimer = Timer.periodic(
    const Duration(seconds: 8),
    (_) {
      if (!mounted) return;

      setState(() {
        quoteIndex++;

        if (quoteIndex >= quotes.length) {
          quoteIndex = 0;
        }
      });
    },
  );
}
  @override

  void initState() {
  super.initState();

  remainingSeconds =
      widget.minute * 60;

  playAudio();
  mulaiRelaksasi();
  startQuote();
}
  Future<void> playAudio() async {
    await player.setReleaseMode(
      ReleaseMode.loop,
    );

    await player.play(
      AssetSource(
        widget.audio.replaceFirst(
          'assets/',
          '',
        ),
      ),
    );
  }

  void mulaiRelaksasi() {
  timer?.cancel();

  timer = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
      if (!mounted) return;

      if (remainingSeconds <= 0) {
        selesai();
        return;
      }

      setState(() {
        remainingSeconds--;
      });
    },
  );
}
  Future<void> selesai() async {

    timer?.cancel();

    await player.stop();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "🎉 Relaksasi Selesai",
          ),
          content: const Text(
            "Semoga pikiran Anda lebih tenang.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  String formatTime() {
    int m = remainingSeconds ~/ 60;
    int s = remainingSeconds % 60;

    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF4F7FC),

      appBar: AppBar(
        title: const Text(
          "Sesi Relaksasi",
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.spa,
              size: 120,
              color: Colors.green,
            ),

            const SizedBox(height: 30),

            Text(
              formatTime(),
              style: const TextStyle(
                fontSize: 45,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

          LinearProgressIndicator(
            value:
                1 -
                (remainingSeconds /
                    (widget.minute * 60)),
            minHeight: 10,
            borderRadius:
                BorderRadius.circular(20),
          ),

          const SizedBox(height: 30),
          Text(
          quotes[quoteIndex],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
          const SizedBox(height: 20),

          Text(
            "${widget.minute} Menit",
            style: const TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
          ],
        ),
      ),
    );
  }
}