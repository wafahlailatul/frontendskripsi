import 'package:get/get.dart';

import '../controllers/heartmonitor_controller.dart';

class HeartmonitorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HeartmonitorController>(
      () => HeartmonitorController(),
    );
  }
}
