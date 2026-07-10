import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart';

class OtpController {
  final TextEditingController otpController = TextEditingController();

  /// VERIFY OTP REGISTER
  Future<Map<String, dynamic>> verifyOtpRegister(String email) async {
    final otp = otpController.text.trim();

    print("========== VERIFY OTP ==========");
    print("EMAIL : $email");
    print("OTP   : $otp");

    try {
      final result = await ApiService.verifyOtpRegister(
        email.trim().toLowerCase(),
        otp,
      );

      print("RESULT : $result");

      return result;
    } catch (e) {
      print("ERROR VERIFY OTP : $e");

      return {
        "status": "error",
        "message": "Gagal verifikasi OTP"
      };
    }
  }

  /// RESEND OTP REGISTER
Future<Map<String, dynamic>> resendOtpRegister(String email) async {
  try {
    final result = await ApiService.resendOtpRegister(
      email.trim().toLowerCase(),
    );

    print("RESEND OTP RESULT : $result");

    return result;
  } catch (e) {
    print("ERROR RESEND OTP : $e");

    return {
      "status": "error",
      "message": "Gagal mengirim OTP"
    };
  }
}

  /// CLEANUP
  void dispose() {
    otpController.dispose();
  }
}