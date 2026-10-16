import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cobaaa_controller.dart';

class CobaaaView extends GetView<CobaaaController> {
  const CobaaaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: const SizedBox.expand(), // Halaman kosong & polos
    );
  }
}