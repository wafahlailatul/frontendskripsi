import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/services/health_service.dart';


class HeartmonitorView extends StatefulWidget {
  const HeartmonitorView({super.key});

  @override
  State<HeartmonitorView> createState() =>
      _HeartmonitorViewState();
}

class _HeartmonitorViewState
    extends State<HeartmonitorView> {
  final HealthService service =
      HealthService();

  double? heartRate;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHeartData();
  }

  Future<void> loadHeartData() async {
    bool granted =
        await service.requestPermission();

    if (!granted) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Izin Health Connect ditolak",
          ),
        ),
      );
      return;
    }

    final rate =
        await service.getLatestHeartRate();

    setState(() {
      heartRate = rate;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Heart Monitor"),
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 90,
                  ),
                  const SizedBox(
                      height: 20),
                  Text(
                    heartRate == null
                        ? "-- BPM"
                        : "${heartRate!.toStringAsFixed(0)} BPM",
                    style:
                        const TextStyle(
                      fontSize: 42,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                      height: 10),
                  const Text(
                    "Detak Jantung Terakhir",
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}