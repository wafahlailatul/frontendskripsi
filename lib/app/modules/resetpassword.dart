import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart';
import 'package:kesehatan_jantung/app/modules/login/views/login_view.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;

  const ResetPasswordView({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordView> createState() =>
      _ResetPasswordViewState();
}

class _ResetPasswordViewState
    extends State<ResetPasswordView> {
  final passwordController =
      TextEditingController();

  final confirmController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    final password =
        passwordController.text.trim();

    final confirm =
        confirmController.text.trim();

    if (password.isEmpty ||
        confirm.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Password tidak boleh kosong",
          ),
        ),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Konfirmasi password tidak sama",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result =
          await ApiService.resetPassword(
        widget.email,
        password,
      );

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            result["message"],
          ),
        ),
      );

      if (result["status"] ==
          "success") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const LoginView(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Terjadi kesalahan: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Reset Password"),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Reset password untuk\n${widget.email}",
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 30,
            ),

            TextField(
              controller:
                  passwordController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    "Password Baru",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  confirmController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    "Konfirmasi Password",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : resetPassword,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Simpan Password",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}