import 'package:get/get.dart';

import '../controllers/stress_controller.dart';

class StressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StressController>(
      () => StressController(),
    );
  }
}
