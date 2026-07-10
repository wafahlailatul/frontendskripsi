import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kesehatan_jantung/app/modules/login/views/login_view.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart';
import 'package:kesehatan_jantung/app/services/storage_service.dart';

class ProfilView extends StatefulWidget {
  const ProfilView({super.key});

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  final namaController = TextEditingController();
  final tinggiController = TextEditingController();
  final beratController = TextEditingController();

  DateTime? selectedDate;

  String gender = "Perempuan";

  double bmi = 0;

  String bmiStatus = "--";
  @override
void initState() {
  super.initState();

  tinggiController.addListener(
      calculateBMI);

  beratController.addListener(
      calculateBMI);

  loadProfile();
}

Future<void> loadProfile() async {
  try {
    final result =
        await ApiService.getProfile();

    if (result["status"] == "success") {

      final data = result["data"];

      setState(() {
        namaController.text =
            data["full_name"] ?? "";

        tinggiController.text =
            data["height"].toString();

        beratController.text =
            data["weight"].toString();

        gender =
            data["gender"] ??
            "Perempuan";

        selectedDate =
            DateTime.parse(
              data["birth_date"],
            );

        bmi = double.parse(
          data["bmi"].toString(),
        );
      });
    }
  } catch (e) {
    print(
      "Load profile error: $e",
    );
  }
}


  void calculateBMI() {
    if (tinggiController.text.isEmpty ||
        beratController.text.isEmpty) {
      setState(() {
        bmi = 0;
      });
      return;
    }

    try {
      double tinggi =
          double.parse(tinggiController.text) / 100;

      double berat =
          double.parse(beratController.text);

      setState(() {
        bmi = berat / (tinggi * tinggi);
      });
    } catch (_) {}
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime(
      DateTime.now().year - 17,
      DateTime.now().month,
      DateTime.now().day,
    ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

Future<void> saveProfile() async {
  try {

    if (selectedDate == null) {
      Get.snackbar(
        "Peringatan",
        "Pilih tanggal lahir terlebih dahulu",
      );
      return;
    }
    final now = DateTime.now();

int age = now.year - selectedDate!.year;

if (now.month < selectedDate!.month ||
    (now.month == selectedDate!.month &&
        now.day < selectedDate!.day)) {
  age--;
}

if (age < 17) {
  Get.snackbar(
    "Peringatan",
    "Umur minimal 17 tahun",
  );
  return;
}

    final result =
        await ApiService.saveProfile(

      fullName:
          namaController.text,

      birthDate:
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",

      gender: gender,

      height: double.parse(
        tinggiController.text,
      ),

      weight: double.parse(
        beratController.text,
      ),
    );
if (result["status"] == "success") {

  final data = result["data"];

  setState(() {

    bmi = double.parse(
      data["bmi"].toString(),
    );


    bmiStatus =
        data["bmi_status"];

  });


  Get.snackbar(
    "Berhasil",
    "Profil berhasil disimpan",
    snackPosition:
        SnackPosition.BOTTOM,
  );


      Get.snackbar(
        "Berhasil",
        "Profil berhasil disimpan",
        snackPosition:
            SnackPosition.BOTTOM,
      );

    } else {

      Get.snackbar(
        "Gagal",
        result["message"],
      );
    }

  } catch (e) {

    Get.snackbar(
      "Error",
      e.toString(),
    );
  }
}

  String getKategoriBMI() {
    if (bmi == 0) return "--";

    if (bmi < 18.5) {
      return "Kurus";
    } else if (bmi < 25) {
      return "Normal";
    } else if (bmi < 30) {
      return "Gemuk";
    } else {
      return "Obesitas";
    }
  }

  Future<void> logout() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari akun ini?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  if (confirm != true) return;

  try {
    await ApiService.logout();

    await StorageService.removeToken();

    Get.offAll(() => const LoginView());

    Get.snackbar(
      "Berhasil",
      "Anda telah logout",
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    Get.snackbar(
      "Error",
      "Logout gagal",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Profil Pengguna",
          style: TextStyle(
            color: Color(0xFF123B6A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            /// FOTO
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue,
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor:
                    Colors.blue.shade100,
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
                prefixIcon:
                    const Icon(Icons.person),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            InkWell(
              onTap: pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                    ),
                    const SizedBox(width: 10),

                    Text(
                      selectedDate == null
                          ? "Tanggal Lahir"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField(
              value: gender,
              decoration: InputDecoration(
                labelText: "Jenis Kelamin",
                prefixIcon:
                    const Icon(Icons.people),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Laki-laki",
                  child: Text("Laki-laki"),
                ),
                DropdownMenuItem(
                  value: "Perempuan",
                  child: Text("Perempuan"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  gender = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: tinggiController,
              keyboardType:
                  TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    "Tinggi Badan (cm)",
                prefixIcon:
                    const Icon(Icons.height),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: beratController,
              keyboardType:
                  TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    "Berat Badan (kg)",
                prefixIcon:
                    const Icon(Icons.monitor_weight),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// BMI CARD
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4DA6FF),
                    Color(0xFF1976D2),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(25),
              ),
              child: Column(
                children: [

                  const Text(
                    "Body Mass Index",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    bmi == 0
                        ? "--"
                        : bmi.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  Text(
                    getKategoriBMI(),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

           const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Simpan Profil",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: logout,
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                ),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}