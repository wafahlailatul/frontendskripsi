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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();

  String _selectedType = 'Minum Obat';
  TimeOfDay _selectedTime = TimeOfDay.now();

  // 9 kategori preset + 1 "Lainnya" untuk custom
  final List<Map<String, dynamic>> _categoryOptions = [
    {'label': 'Minum Obat',           'icon': Icons.medication_rounded},
    {'label': 'Cek Tekanan Darah',    'icon': Icons.monitor_heart_rounded},
    {'label': 'Olahraga Jantung',     'icon': Icons.directions_run_rounded},
    {'label': 'Minum Air Putih',      'icon': Icons.local_drink_rounded},
    {'label': 'Istirahat / Tidur',    'icon': Icons.bedtime_rounded},
    {'label': 'Cek Gula Darah',       'icon': Icons.bloodtype_rounded},
    {'label': 'Meditasi / Relaksasi', 'icon': Icons.self_improvement_rounded},
    {'label': 'Kontrol ke Dokter',    'icon': Icons.local_hospital_rounded},
    {'label': 'Makan Sehat',          'icon': Icons.restaurant_rounded},
    {'label': 'Lainnya',              'icon': Icons.edit_note_rounded},
  ];

  bool get _isCustomCategory => _selectedType == 'Lainnya';

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  // =============================================
  // LOAD REMINDERS
  // =============================================
  Future<void> loadReminders() async {
    try {
      final result = await ApiService.getReminders();
      if (!mounted) return;

      if (result["status"] == "success") {
        setState(() {
          _reminders.clear();
          for (var item in result["data"]) {
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
    } catch (e) {
      debugPrint("Load Reminder Error: $e");
    }
  }

  // =============================================
  // ADD REMINDER
  // =============================================
  Future<void> addReminder() async {
    if (_titleController.text.trim().isEmpty) {
      showSnackBar("Nama pengingat tidak boleh kosong");
      return;
    }

    // Jika pilih "Lainnya", gunakan input custom
    final String finalCategory = _isCustomCategory
        ? _customCategoryController.text.trim()
        : _selectedType;

    if (finalCategory.isEmpty) {
      showSnackBar("Tuliskan nama kategori pengingat Anda");
      return;
    }

    try {
      final result = await ApiService.addReminder(
        title: _titleController.text.trim(),
        category: finalCategory,
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        isActive: true,
      );

      if (result["status"] == "success") {
        final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        await ReminderService.scheduleDailyReminder(
          id: notificationId,
          title: _titleController.text.trim(),
          body: finalCategory,
          hour: _selectedTime.hour,
          minute: _selectedTime.minute,
        );

        _titleController.clear();
        _customCategoryController.clear();
        setState(() => _selectedType = 'Minum Obat');

        await loadReminders();
        showSnackBar("Pengingat berhasil ditambahkan");
      } else {
        showSnackBar(result["message"] ?? "Gagal menambahkan pengingat");
      }
    } catch (e) {
      debugPrint("Add Reminder Error: $e");
      showSnackBar("Terjadi kesalahan");
    }
  }

  // =============================================
  // DELETE REMINDER
  // =============================================
  Future<void> _deleteReminder(int index) async {
    final reminder = _reminders[index];

    if (reminder.id == null || reminder.id!.isEmpty) {
      showSnackBar("ID pengingat tidak ditemukan");
      return;
    }

    try {
      final result = await ApiService.deleteReminder(reminder.id!);

      if (result["status"] == "success") {
        await ReminderService.cancelReminder(reminder.id.hashCode);
        setState(() => _reminders.removeAt(index));
        showSnackBar("Pengingat berhasil dihapus");
      } else {
        showSnackBar(result["message"] ?? "Gagal menghapus");
      }
    } catch (e) {
      showSnackBar("Gagal menghapus pengingat");
    }
  }

  // =============================================
  // HELPER: icon berdasarkan kategori
  // =============================================
  IconData _getIconForCategory(String category) {
    final match = _categoryOptions.firstWhere(
      (c) => c['label'] == category,
      orElse: () => {'label': 'Lainnya', 'icon': Icons.notifications_rounded},
    );
    return match['icon'] as IconData;
  }

  // =============================================
  // HELPER: warna per kategori
  // =============================================
  Color _getColorForCategory(String category) {
    const Map<String, Color> colorMap = {
      'Minum Obat':           Color(0xFF10B981),
      'Cek Tekanan Darah':    Color(0xFFEF4444),
      'Olahraga Jantung':     Color(0xFF3B82F6),
      'Minum Air Putih':      Color(0xFF06B6D4),
      'Istirahat / Tidur':    Color(0xFF8B5CF6),
      'Cek Gula Darah':       Color(0xFFF59E0B),
      'Meditasi / Relaksasi': Color(0xFF14B8A6),
      'Kontrol ke Dokter':    Color(0xFFEC4899),
      'Makan Sehat':          Color(0xFF84CC16),
    };
    return colorMap[category] ?? const Color(0xFF64748B);
  }

  // =============================================
  // BUILD
  // =============================================
  @override
  Widget build(BuildContext context) {
    const Color lightGreenBg = Color(0xFFF0FDF4);
    const Color slateDark = Color(0xFF1E293B);
    const Color slateLight = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: lightGreenBg,
      appBar: AppBar(
        title: const Text(
          "Pengingat Kesehatan",
          style: TextStyle(fontWeight: FontWeight.bold, color: slateDark),
        ),
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
                  Text(
                    "Belum ada pengingat",
                    style: TextStyle(fontSize: 16, color: slateLight, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tekan + untuk menambahkan pengingat",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
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
                final iconData = _getIconForCategory(reminder.type);
                final iconColor = _getColorForCategory(reminder.type);

                return Dismissible(
                  key: Key(reminder.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon kategori
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconData, color: iconColor, size: 26),
                        ),
                        const SizedBox(width: 16),

                        // Judul + badge kategori
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: slateDark,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: iconColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  reminder.type,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: iconColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Waktu + tombol hapus
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: iconColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _deleteReminder(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      "Hapus",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderBottomSheet(context),
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Tambah",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // =============================================
  // BOTTOM SHEET TAMBAH PENGINGAT
  // =============================================
  void _showAddReminderBottomSheet(BuildContext context) {
    _customCategoryController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Header ──
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.alarm_add_rounded, color: Color(0xFF10B981)),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Tambah Pengingat",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Nama aktivitas ──
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: "Contoh: Obat Amlodipine 5mg",
                        labelText: "Nama Aktivitas / Obat",
                        prefixIcon: const Icon(Icons.edit_rounded, color: Color(0xFF10B981)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Label kategori ──
                    const Text(
                      "Pilih Kategori",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Grid kategori (Wrap — otomatis bungkus, tidak overflow) ──
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categoryOptions.map((cat) {
                        final bool isSelected = _selectedType == cat['label'];
                        final bool isLainnya = cat['label'] == 'Lainnya';
                        final Color catColor = isLainnya
                            ? const Color(0xFF64748B)
                            : _getColorForCategory(cat['label'] as String);

                        return GestureDetector(
                          onTap: () {
                            setModalState(() => _selectedType = cat['label'] as String);
                            setState(() => _selectedType = cat['label'] as String);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 70,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? catColor.withOpacity(0.15)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? catColor : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat['icon'] as IconData,
                                  color: isSelected ? catColor : Colors.grey.shade500,
                                  size: 24,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  cat['label'] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? catColor : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // ── Input custom (muncul hanya jika pilih "Lainnya") ──
                    if (_selectedType == 'Lainnya') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _customCategoryController,
                        decoration: InputDecoration(
                          hintText: "Contoh: Cek Kolesterol, Fisioterapi...",
                          labelText: "Nama Kategori Kustom",
                          prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF64748B)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF64748B), width: 2),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ── Pilih waktu ──
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF10B981),
                          size: 28,
                        ),
                        title: const Text(
                          "Atur Waktu Pengingat",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          _selectedTime.format(context),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () async {
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (time != null) {
                            setModalState(() => _selectedTime = time);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Tombol simpan ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await addReminder();
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.alarm_add_rounded, color: Colors.white),
                        label: const Text(
                          "Simpan Pengingat",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
      SnackBar(content: Text(text)),
    );
  }
}