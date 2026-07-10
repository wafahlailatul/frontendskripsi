class ReminderModel {

  final String? id;
  final String? userId;
  final String title;
  final String type;
  final int hour;
  final int minute;
  final bool isActive;


  ReminderModel({

    this.id,
    this.userId,
    required this.title,
    required this.type,
    required this.hour,
    required this.minute,
    required this.isActive,

  });

}