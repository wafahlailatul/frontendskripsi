import 'package:flutter/material.dart';
import 'package:kesehatan_jantung/app/modules/remindermodel.dart';
import 'package:kesehatan_jantung/app/services/api_service.dart';
import 'package:kesehatan_jantung/app/services/reminder_service.dart';


class NotifikasiView extends StatefulWidget {
  const NotifikasiView({super.key});

  @override
  State<NotifikasiView> createState() => _NotifikasiViewState();
}
class _NotifikasiViewState extends State<NotifikasiView> {

  final List<ReminderModel> _reminders = [];

  final TextEditingController _titleController =
      TextEditingController();

  String _selectedType = 'Minum Obat';

  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _categories = [
    'Minum Obat',
    'Cek Tekanan Darah',
    'Olahraga Jantung',
  ];

  bool isLoading = false;
@override
void initState() {
  super.initState();

  loadReminders();
}

Future<void> loadReminders() async {
  try {

    final result = await ApiService.getReminders();

    print("HASIL REMINDER:");
    print(result);


    if (!mounted) return;


    if(result["status"] == "success") {

      setState(() {

        _reminders.clear();

        for (var item in result["data"]) {

          print("ITEM:");
          print(item);


          _reminders.add(

            ReminderModel(

              id: item["_id"],

              userId: item["user_id"],

              title: item["title"],

              type: item["category"],

              hour: item["hour"],

              minute: item["minute"],

              isActive: item["is_active"] ?? true,

            ),

          );

        }

      });

    }


  } catch(e){

    print(e);

  }
}
Future<void> addReminder() async {

  if (_titleController.text.trim().isEmpty) {

    showSnackBar(
      "Nama pengingat tidak boleh kosong"
    );

    return;

  }


  try {


    final result = await ApiService.addReminder(

      title: _titleController.text.trim(),

      category: _selectedType,

      hour: _selectedTime.hour,

      minute: _selectedTime.minute,

      isActive: true,

    );


    if(result["status"] == "success"){


      final notificationId =
          DateTime.now().millisecondsSinceEpoch ~/ 1000;



      await ReminderService.scheduleDailyReminder(

        id: notificationId,

        title: _titleController.text.trim(),

        body: _selectedType,

        hour: _selectedTime.hour,

        minute: _selectedTime.minute,

      );



      _titleController.clear();


      await loadReminders();


      showSnackBar(
        "Pengingat berhasil ditambahkan"
      );


    }else{


      showSnackBar(
        result["message"] ?? 
        "Gagal menambahkan pengingat"
      );


    }


  }catch(e){

    debugPrint(
      "Add Reminder Error: $e"
    );

    showSnackBar(
      "Terjadi kesalahan"
    );

  }

}
Future<void> _deleteReminder(int index) async {

  final reminder = _reminders[index];

  print("DELETE CLICK");
  print("ID : ${reminder.id}");

  if (reminder.id == null || reminder.id!.isEmpty) {

    showSnackBar("ID pengingat tidak ditemukan");

    return;

  }

  try {

    final result = await ApiService.deleteReminder(
      reminder.id!,
    );

    print(result);

    if (result["status"] == "success") {

      await ReminderService.cancelReminder(
        reminder.id.hashCode,
      );

      setState(() {

        _reminders.removeAt(index);

      });

      showSnackBar("Pengingat berhasil dihapus");

    } else {

      showSnackBar(
        result["message"],
      );

    }

  } catch (e) {

    print(e);

    showSnackBar(
      "Gagal menghapus pengingat",
    );

  }

}
@override
void dispose() {
  _titleController.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF10B981);
    const Color lightGreenBg = Color(0xFFF0FDF4);
    const Color slateDark = Color(0xFF1E293B);
    const Color slateLight = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: lightGreenBg,
      appBar: AppBar(
        title: const Text("Pengingat Medis", style: TextStyle(fontWeight: FontWeight.bold, color: slateDark)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off_rounded, size: 70, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("Belum ada pengingat", style: TextStyle(fontSize: 16, color: slateLight, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                final String formattedTime =
                    "${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}";

                // FITUR SWIPE TO DELETE (GESER KARTU UNTUK MENGHAPUS)
                return Dismissible(
                  key: Key(reminder.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 30),
                  ),
                  onDismissed: (direction) => _deleteReminder(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(
                            reminder.type == 'Minum Obat'
                                ? Icons.medication_rounded
                                : reminder.type == 'Cek Tekanan Darah'
                                    ? Icons.favorite_rounded
                                    : Icons.directions_run_rounded,
                            color: primaryGreen,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reminder.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: slateDark)),
                              const SizedBox(height: 4),
                              Text("${reminder.type} • Setiap Hari", style: const TextStyle(fontSize: 13, color: slateLight)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [

                            Text(
                              formattedTime,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),

                            const SizedBox(height: 10),

                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _deleteReminder(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [

                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
                                      size: 18,
                                    ),

                                    SizedBox(width: 4),

                                    Text(
                                      "Hapus",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),

                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    _showAddReminderBottomSheet(context);
  },
  backgroundColor: primaryGreen,
  child: const Icon(
    Icons.add,
    color: Colors.white,
  ),
),
    );
  }

  void _showAddReminderBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tambah Pengingat", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: "Contoh: Obat Amlodipine 5mg",
                        labelText: "Nama Aktivitas / Obat",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                      onChanged: (val) => setModalState(() => _selectedType = val!),
                      decoration: InputDecoration(labelText: "Kategori", border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: const Icon(Icons.access_time_rounded, color: Color(0xFF10B981), size: 28),
                      title: const Text("Atur Waktu Pengingat", style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(_selectedTime.format(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () async {
                        final TimeOfDay? time = await showTimePicker(context: context, initialTime: _selectedTime);
                        if (time != null) setModalState(() => _selectedTime = time);
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {

                          await addReminder();

                          if(context.mounted){
                            Navigator.pop(context);
                          }

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Simpan Pengingat", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  void showSnackBar(String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}
}