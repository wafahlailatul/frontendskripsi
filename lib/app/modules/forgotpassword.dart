import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/modules/otp/views/otp_view.dart';
import 'package:kesehatan_jantung/app/modules/verifyotp_view.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    final email = emailController.text.trim();

    // VALIDASI EMAIL KOSONG
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email tidak boleh kosong"),
        ),
      );
      return;
    }

    try {
      final result = await ApiService.forgotPassword(email);

      final message = result?["message"] ?? "Tidak ada respon dari server";
      final status = result?["status"] ?? "error";

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      // Jika sukses pindah ke OTP
      if (status == "success") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyOtpView(email: email),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi error: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lupa Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sendOtp,
                child: const Text("Kirim OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}