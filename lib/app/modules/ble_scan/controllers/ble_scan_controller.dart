import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleScanController extends GetxController {

  RxBool isScanning = false.obs;

  RxBool isConnected = false.obs;

  RxString deviceName = "Belum Terhubung".obs;

  RxString deviceId = "".obs;

  RxInt heartRate = 0.obs;

  BluetoothDevice? connectedDevice;

  RxList<ScanResult> devices =
      <ScanResult>[].obs;
}