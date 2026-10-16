import 'package:get/get.dart';

import '../controllers/cobaaa_controller.dart';

class CobaaaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CobaaaController>(
      () => CobaaaController(),
    );
  }
}
