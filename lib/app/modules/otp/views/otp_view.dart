import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/modules/login/views/login_view.dart';
import 'package:kesehatan_jantung/app/modules/otp/controllers/otp_controller.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart';

class OtpView extends StatefulWidget {

  final String email;

  const OtpView({
    super.key,
    required this.email,
  });

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {

  final OtpController controller =
      OtpController();

  String message = "";
  Color messageColor = Colors.red;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFEAF7FF),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 25,
              ),

              child: Column(
                children: [

                  /// LOGO
                  Image.asset(
                    'assets/images/logo jntg.png',
                    width: 120,
                  ),

                  const SizedBox(height: 15),

                  /// TITLE
                  const Text(
                    "HEARTIFY",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// CARD OTP
                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),

                      border: Border.all(
                        color: Colors.blue,
                        width: 1.5,
                      ),
                    ),

                    child: Column(
                      children: [

                        /// JUDUL
                        const Text(
                          "Verifikasi OTP",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                            fontFamily: 'Serif',
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// EMAIL
                        Text(
                          "Kode OTP telah dikirim ke\n${widget.email}",

                          textAlign:
                              TextAlign.center,

                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 35),

                        /// OTP FIELD
                        TextField(
                          controller:
                              controller
                                  .otpController,

                          keyboardType:
                              TextInputType
                                  .number,

                          maxLength: 6,

                          textAlign:
                              TextAlign.center,

                          style: const TextStyle(
                            fontSize: 28,
                            letterSpacing: 12,
                            fontWeight:
                                FontWeight.bold,
                          ),

                          decoration:
                              InputDecoration(
                            counterText: "",

                            hintText:
                                "000000",

                            filled: true,

                            fillColor:
                                Colors.white,

                            contentPadding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 18,
                            ),

                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                15,
                              ),

                              borderSide:
                                  const BorderSide(
                                color:
                                    Colors.black54,
                              ),
                            ),

                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                15,
                              ),

                              borderSide:
                                  const BorderSide(
                                color:
                                    Colors.blue,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// INFO OTP
                        const Align(
                          alignment:
                              Alignment.centerLeft,

                          child: Text(
                            "OTP harus terdiri dari 6 digit angka",
                            style: TextStyle(
                              color:
                                  Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// MESSAGE
                        if (message.isNotEmpty)
                          Container(
                            width:
                                double.infinity,

                            padding:
                                const EdgeInsets
                                    .all(12),

                            decoration:
                                BoxDecoration(
                              color:
                                  messageColor
                                      .withOpacity(
                                0.1,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),

                            child: Text(
                              message,

                              textAlign:
                                  TextAlign.center,

                              style: TextStyle(
                                color:
                                    messageColor,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),

                        const SizedBox(height: 30),

                        /// BUTTON VERIFIKASI
                        SizedBox(
                          width: 150,
                          height: 50,

                          child: ElevatedButton(

                            onPressed:
                                () async {

                              /// VALIDASI OTP
                              if (controller
                                      .otpController
                                      .text
                                      .length !=
                                  6) {

                                setState(() {

                                  message =
                                      "OTP harus 6 digit";

                                  messageColor =
                                      Colors.red;
                                });

                                return;
                              }

                              setState(() {
                                isLoading =
                                    true;
                              });

                              final result = await controller.verifyOtpRegister(widget.email);

                              setState(() {
                                isLoading =
                                    false;
                              });

                              /// OTP VALID
                              if (result[
                                      'status'] ==
                                  'success') {

                                setState(() {

                                  message =
                                      "OTP valid";

                                  messageColor =
                                      Colors.green;
                                });

                                /// PINDAH LOGIN
                                Future.delayed(
                                  const Duration(
                                    seconds: 1,
                                  ),

                                  () {

                                    Navigator.pushReplacement(
                                      context,

                                      MaterialPageRoute(
                                        builder:
                                            (
                                              context,
                                            ) =>
                                                const LoginView(),
                                      ),
                                    );
                                  },
                                );

                              } else {

                                /// OTP SALAH
                                setState(() {

                                  message =
                                      "OTP tidak valid";

                                  messageColor =
                                      Colors.red;
                                });
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
                                    BorderRadius.circular(
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
                                          Colors
                                              .white,
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : const Text(
                                    "Verifikasi",
                                    style:
                                        TextStyle(
                                      color:
                                          Colors
                                              .white,

                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// RESEND OTP
                        TextButton(

                          onPressed: () async {
                          final result = await ApiService.resendOtpRegister(
                            widget.email.trim().toLowerCase(),
                          );
                            setState(() {

                              message =
                                  result[
                                      'message'];

                              messageColor =
                                  Colors.blue;
                            });
                          },

                          child: const Text(
                            "Kirim Ulang OTP",

                            style: TextStyle(
                              color:
                                  Colors.blue,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}