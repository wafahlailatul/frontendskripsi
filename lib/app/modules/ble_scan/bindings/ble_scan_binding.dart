import 'package:get/get.dart';

import '../controllers/ble_scan_controller.dart';

class BleScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BleScanController>(
      () => BleScanController(),
    );
  }
}
