import 'package:get/get.dart';

import '../controllers/progress_aktifitas_controller.dart';

class ProgressAktifitasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgressAktifitasController>(
      () => ProgressAktifitasController(),
    );
  }
}
