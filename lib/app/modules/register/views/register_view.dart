import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/modules/login/views/login_view.dart';
import 'package:kesehatan_jantung/app/modules/otp/views/otp_view.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() =>
      _RegisterViewState();
}

class _RegisterViewState
    extends State<RegisterView> {

  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController
      confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool isPasswordObscured = true;

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

              /// CARD REGISTER
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
                      "Daftar Akun Baru",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Lengkapi data di bawah ini",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 35),

                    /// USERNAME
                    buildFieldTitle("Username"),

                    const SizedBox(height: 8),

                    buildTextField(
                      controller:
                          usernameController,

                      hint: "Username",

                      icon: Icons.person_outline,
                    ),

                    const SizedBox(height: 18),

                    /// EMAIL
                    buildFieldTitle("Email"),

                    const SizedBox(height: 8),

                    buildTextField(
                      controller:
                          emailController,

                      hint: "Email",

                      icon:
                          Icons.email_outlined,
                    ),

                    const SizedBox(height: 18),

                    /// PASSWORD
                    buildFieldTitle("Password"),

                    const SizedBox(height: 8),

                    buildTextField(
                      controller:
                          passwordController,

                      hint: "Password",

                      icon:
                          Icons.lock_outline,

                      isPassword: true,
                    ),

                    const SizedBox(height: 18),

                    /// KONFIRM PASSWORD
                    buildFieldTitle(
                        "Konfirmasi Password"),

                    const SizedBox(height: 8),

                    buildTextField(
                      controller:
                          confirmPasswordController,

                      hint: "Password",

                      icon:
                          Icons.lock_outline,

                      isPassword: true,
                    ),

                    const SizedBox(height: 35),

                    /// BUTTON DAFTAR
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

                          // VALIDASI
                          if (usernameController
                              .text
                              .isEmpty) {

                            showMessage(
                              "Username wajib diisi",
                            );

                            return;
                          }

                          if (emailController
                              .text
                              .isEmpty) {

                            showMessage(
                              "Email wajib diisi",
                            );

                            return;
                          }

                          if (passwordController
                              .text
                              .isEmpty) {

                            showMessage(
                              "Password wajib diisi",
                            );

                            return;
                          }

                          if (passwordController
                                  .text !=
                              confirmPasswordController
                                  .text) {

                            showMessage(
                              "Password tidak sama",
                            );

                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          final result =
                              await ApiService.register(

                            usernameController.text,
                            emailController.text,
                            passwordController.text,
                          );

                          setState(() {
                            isLoading = false;
                          });

                          showMessage(
                            result['message'],
                          );

                          // PINDAH OTP
                          if (result['status'] ==
                              'success') {

                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        OtpView(
                                  email:
                                      emailController
                                          .text,
                                ),
                              ),
                            );
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
                                height: 20,
                                width: 20,

                                child:
                                    CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Daftar",
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

                    /// LOGIN
                    GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) =>
                                const LoginView(),
                          ),
                        );
                      },

                      child: const Text(
                        "Sudah punya akun? Masuk",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
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