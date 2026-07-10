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
      backgroundColor: const Color(0xFFEAF7FF),
      body: SafeArea(
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
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Masuk",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
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

                    const SizedBox(height: 20),

                    /// BUTTON LOGIN
                    SizedBox(
                      width: 120,
                      height: 45,
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
                              emailController.text,
                              passwordController.text,
                            );

                            setState(() {
                              isLoading = false;
                            });

                            showMessage(result['message']);

                            if (result['status'] ==
                                'success') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HomeView(),
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });

                            showMessage("Error: $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF9DD2F5),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
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
                                  fontWeight:
                                      FontWeight.bold,
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
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: Colors.pink,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.black54,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 1.5,
          ),
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