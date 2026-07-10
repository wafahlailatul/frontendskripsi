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

              /// CARD REGISTER
              Container(
                width: double.infinity,

                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 25,
                ),

                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(30),

                  border: Border.all(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                ),

                child: Column(
                  children: [

                    const Text(
                      "Daftar akun",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                        fontFamily: 'Serif',
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
                    SizedBox(
                      width: 120,
                      height: 45,

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

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF9DD2F5,
                          ),

                          elevation: 4,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
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
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight
                                          .bold,
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