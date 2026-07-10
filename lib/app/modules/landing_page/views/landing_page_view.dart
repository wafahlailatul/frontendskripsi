import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/modules/login/views/login_view.dart';
import 'package:kesehatan_jantung/app/modules/register/views/register_view.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart';

class LandingPageView extends StatefulWidget {
  const LandingPageView({super.key});

  @override
  State<LandingPageView> createState() => _LandingPageViewState();
}

class _LandingPageViewState extends State<LandingPageView> {

  String statusBackend = "Menghubungkan ke server...";

  @override
  void initState() {
    super.initState();

    connectBackend();
  }

  Future<void> connectBackend() async {

    try {

      final data = await ApiService.getData();

      setState(() {
        statusBackend = data['message'];
      });

    } catch (e) {

      setState(() {
        statusBackend = "Backend tidak terhubung";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFF90CAF9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Image.asset(
                'assets/images/logo jntg.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 20),

              const Text(
                "HEARTIFY",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              // STATUS BACKEND
              Text(
                statusBackend,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: 220,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginView(),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),

                  child: const Text(
                    "Masuk",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: 220,
                height: 45,
                child: OutlinedButton(
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterView(),
                      ),
                    );
                  },

                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),

                  child: const Text(
                    "Daftar",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}