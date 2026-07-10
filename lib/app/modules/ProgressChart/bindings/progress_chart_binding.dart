import 'package:get/get.dart';

import '../controllers/progress_chart_controller.dart';

class ProgressChartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgressChartController>(
      () => ProgressChartController(),
    );
  }
}
