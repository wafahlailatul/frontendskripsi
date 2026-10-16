import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kesehatan_jantung/app/modules/forgotpassword.dart';

import 'package:kesehatan_jantung/app/modules/home/views/home_view.dart';
import 'package:kesehatan_jantung/app/modules/register/views/register_view.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart';
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool isLoading = false;
  bool isPasswordObscured = true;
Future<void> signInGoogle() async {
  try {

    final GoogleSignIn googleSignIn = GoogleSignIn();

    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();

    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn();

    if (googleUser == null) return;

    final googleAuth =
        await googleUser.authentication;

    final credential =
        GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance
            .signInWithCredential(credential);

    final user = userCredential.user;

    if (user == null) return;

    final result = await ApiService.googleLogin(
      firebaseUid: user.uid,
      email: user.email ?? "",
      username: user.displayName ?? "",
      photo: user.photoURL ?? "",
    );

    if (result["status"] == "success") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeView(),
        ),
      );
    } else {
      showMessage(result["message"]);
    }

  } catch (e) {
    showMessage("Login Google gagal\n$e");
  }
}

Future<void> resetPassword() async {
  if (emailController.text.trim().isEmpty) {
    showMessage("Masukkan email terlebih dahulu");
    return;
  }

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: emailController.text.trim(),
    );

    showMessage(
      "Link reset password telah dikirim ke email Anda.",
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      showMessage("Email tidak terdaftar.");
    } else if (e.code == 'invalid-email') {
      showMessage("Format email tidak valid.");
    } else {
      showMessage(e.message ?? "Terjadi kesalahan");
    }
  } catch (e) {
    showMessage("Error: $e");
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFBAE6FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              /// LOGO
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo jntg.png',
                      width: 120,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "HEARTIFY",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// CARD LOGIN
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Selamat Datang",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Silakan masuk ke akun Anda",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 35),

                    /// EMAIL
                    buildFieldTitle("Email"),
                    const SizedBox(height: 8),
                    buildTextField(
                      controller: emailController,
                      hint: "Email",
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 18),

                    /// PASSWORD
                    buildFieldTitle("Password"),
                    const SizedBox(height: 8),
                    buildTextField(
                      controller: passwordController,
                      hint: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text(
                                "Reset Password",
                              ),
                              content: const Text(
                                "Link reset password akan dikirim ke email yang Anda masukkan.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Batal"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ForgotPasswordView(),
                                      ),
                                    );

                                  },
                                  child: const Text("Kirim"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          "Lupa Password?",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ),

                    const SizedBox(height: 30),

                    /// BUTTON LOGIN
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (emailController.text.isEmpty) {
                            showMessage("Email wajib diisi");
                            return;
                          }

                          if (passwordController.text.isEmpty) {
                            showMessage("Password wajib diisi");
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            final result =
                                await ApiService.login(
                              emailController.text
                                  .trim()
                                  .toLowerCase(),
                              passwordController.text,
                            );

                            setState(() {
                              isLoading = false;
                            });

                            if (result['status'] == 'success') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HomeView(),
                                ),
                              );
                            } else {
                              // Pesan error yang ramah user
                              final rawMsg = (result['message'] ?? '').toString();
                              String friendlyMsg;

                              if (rawMsg.contains('tidak ditemukan') ||
                                  rawMsg.contains('not found') ||
                                  rawMsg.contains('404')) {
                                friendlyMsg = 'Akun tidak terdaftar. Silakan daftar terlebih dahulu.';
                              } else if (rawMsg.contains('Password salah') ||
                                  rawMsg.contains('password')) {
                                friendlyMsg = 'Password salah. Silakan coba lagi.';
                              } else if (rawMsg.isEmpty) {
                                friendlyMsg = 'Login gagal. Periksa koneksi internet Anda.';
                              } else {
                                friendlyMsg = rawMsg;
                              }

                              showMessage(friendlyMsg);
                            }
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });

                            showMessage("Gagal terhubung ke server. Periksa koneksi internet Anda.");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Masuk",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const RegisterView(),
                          ),
                        );
                      },
                      child: const Text(
                        "Belum punya akun? Daftar",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

Row(
  children: [
    Expanded(
      child: Divider(
        color: Colors.grey.shade400,
      ),
    ),
    const Padding(
      padding:
          EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Text(
        "atau",
      ),
    ),
    Expanded(
      child: Divider(
        color: Colors.grey.shade400,
      ),
    ),
  ],
),

const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  height: 55,
  child: OutlinedButton.icon(
    onPressed: signInGoogle,
    icon: const Icon(
      Icons.g_mobiledata,
      color: Colors.red,
      size: 35,
    ),
    label: const Text(
      "Masuk dengan Google",
      style: TextStyle(
        fontSize: 16,
        color: Colors.black87,
        fontWeight:
            FontWeight.w600,
      ),
    ),
    style:
        OutlinedButton.styleFrom(
      backgroundColor:
          Colors.white,
      side: BorderSide(
        color:
            Colors.grey.shade300,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          15,
        ),
      ),
    ),
  ),
),

              const SizedBox(height: 40),
            ],
          ),
        ),
        ),
      ),
    );
  }

  /// TITLE
  Widget buildFieldTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// TEXTFIELD
  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? isPasswordObscured : false,
      style: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF2563EB),
          size: 22,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordObscured
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordObscured = !isPasswordObscured;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }

  /// SNACKBAR
  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}