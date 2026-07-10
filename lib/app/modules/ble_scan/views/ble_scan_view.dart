import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:kesehatan_jantung/app/modules/ble_scan/controllers/ble_scan_controller.dart';

class BleScanView extends StatefulWidget {
  const BleScanView({super.key});

  @override
  State<BleScanView> createState() => _BleScanViewState();
}

class _BleScanViewState extends State<BleScanView> {
  final BleScanController ble = Get.put(
    BleScanController(),
  );

  @override
  void initState() {
    super.initState();

    FlutterBluePlus.scanResults.listen(
      (results) {
        ble.devices.value = results;

        for (var result in results) {
          print(
            "DEVICE : ${result.device.platformName}",
          );

          print(
            "ID : ${result.device.remoteId}",
          );
        }
      },
    );
  }

  Future<void> startScan() async {
    try {
      ble.devices.clear();

      ble.isScanning.value = true;

      print("START SCAN");

      await FlutterBluePlus.startScan(
        timeout: const Duration(
          seconds: 5,
        ),
      );

      await Future.delayed(
        const Duration(seconds: 5),
      );

      await FlutterBluePlus.stopScan();

      print("SCAN SELESAI");

      ble.isScanning.value = false;
    } catch (e) {
      print("SCAN ERROR : $e");

      ble.isScanning.value = false;
    }
  }

  Future<void> connectDevice(
    BluetoothDevice device,
  ) async {
    try {
      print(
        "Mencoba connect ke ${device.platformName}",
      );

      await device.connect(
        timeout: const Duration(
          seconds: 15,
        ),
      );

      print("BERHASIL CONNECT");

      ble.connectedDevice = device;
      ble.isConnected.value = true;

      ble.deviceName.value =
          device.platformName;

      ble.deviceId.value =
          device.remoteId.toString();

      List<BluetoothService> services =
          await device.discoverServices();

      print(
        "JUMLAH SERVICE : ${services.length}",
      );

      for (BluetoothService service
          in services) {
        print(
          "================================",
        );

        print(
          "SERVICE : ${service.uuid}",
        );

        for (BluetoothCharacteristic c
            in service.characteristics) {
          print(
            "CHAR : ${c.uuid}",
          );

          print(
            "READ : ${c.properties.read}",
          );

          print(
            "WRITE : ${c.properties.write}",
          );

          print(
            "NOTIFY : ${c.properties.notify}",
          );

          // =====================
          // READ
          // =====================
          if (c.properties.read) {
            try {
              var value =
                  await c.read();

              print(
                "VALUE : $value",
              );
            } catch (e) {
              print(
                "READ ERROR : $e",
              );
            }
          }

          // =====================
          // HEART RATE 2A37
          // =====================
          if (c.uuid
                  .toString()
                  .toLowerCase() ==
              "2a37") {
            print(
              "=== HEART RATE SERVICE DITEMUKAN ===",
            );

            try {
              await c.setNotifyValue(
                true,
              );

              print(
                "BERHASIL AKTIFKAN NOTIFY 2A37",
              );

              c.lastValueStream.listen(
                (value) {
                  print(
                    "HEART RATE RAW : $value",
                  );

                  if (value.length > 1) {
                    int bpm =
                        value[1];

                    print(
                      "HEART RATE = $bpm BPM",
                    );
                  }
                },
              );
            } catch (e) {
              print(
                "HEART RATE ERROR : $e",
              );
            }
          }

          // =====================
          // NOTIFY UMUM
          // =====================
          if (c.properties.notify) {
            try {
              await c.setNotifyValue(
                true,
              );

              c.lastValueStream.listen(
                (value) {
                  print(
                    "NOTIFY ${c.uuid} : $value",
                  );
                },
              );
            } catch (e) {
              print(
                "NOTIFY ERROR : $e",
              );
            }
          }
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "${device.platformName} berhasil terhubung",
          ),
        ),
      );
    } catch (e) {
      print(
        "ERROR CONNECT : $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Connection Failed: $e",
          ),
        ),
      );
    }
  }

  Future<void> disconnectDevice() async {
    try {
      if (ble.connectedDevice != null) {
        await ble.connectedDevice!
            .disconnect();

        ble.isConnected.value =
            false;

        ble.deviceName.value = "-";
        ble.deviceId.value = "-";

        print(
          "DEVICE DISCONNECT",
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Perangkat diputus",
            ),
          ),
        );
      }
    } catch (e) {
      print(
        "DISCONNECT ERROR : $e",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan Smartband",
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),

          Obx(
            () => Card(
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  children: [
                    Text(
                      ble.isConnected.value
                          ? "TERHUBUNG"
                          : "BELUM TERHUBUNG",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color: ble
                                .isConnected
                                .value
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      ble.deviceName.value,
                    ),

                    Text(
                      ble.deviceId.value,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          Obx(
            () => ElevatedButton(
              onPressed:
                  ble.isScanning.value
                      ? null
                      : startScan,
              child: Text(
                ble.isScanning.value
                    ? "Scanning..."
                    : "Scan Device",
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Obx(
            () => ble.isConnected.value
                ? ElevatedButton(
                    onPressed:
                        disconnectDevice,
                    child: const Text(
                      "Disconnect",
                    ),
                  )
                : const SizedBox(),
          ),

          const SizedBox(
            height: 10,
          ),

          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount:
                    ble.devices.length,
                itemBuilder:
                    (context, index) {
                  final result =
                      ble.devices[index];

                  final device =
                      result.device;

                  return Card(
                    margin:
                        const EdgeInsets.all(
                      10,
                    ),
                    child: ListTile(
                      leading:
                          const Icon(
                        Icons.watch,
                      ),
                      title: Text(
                        device.platformName
                                .isEmpty
                            ? "Unknown Device"
                            : device
                                .platformName,
                      ),
                      subtitle: Text(
                        device.remoteId
                            .toString(),
                      ),
                      trailing:
                          ElevatedButton(
                        onPressed: () {
                          connectDevice(
                            device,
                          );
                        },
                        child: const Text(
                          "Hubungkan",
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}