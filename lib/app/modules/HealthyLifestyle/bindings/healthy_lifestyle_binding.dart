import 'package:get/get.dart';

import '../controllers/healthy_lifestyle_controller.dart';

class HealthyLifestyleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HealthyLifestyleController>(
      () => HealthyLifestyleController(),
    );
  }
}
