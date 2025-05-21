class AppointmentModel {
  final int? id;
  final String title;
  final String location;
  final String note;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String reminder;
  final String status; // ✅ pending / done / skipped

  AppointmentModel({
    this.id,
    required this.title,
    required this.location,
    required this.note,
    required this.startTime,
    required this.endTime,
    required this.isAllDay,
    required this.reminder,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'note': note,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_all_day': isAllDay ? 1 : 0,
      'reminder': reminder,
      'status': status,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'],
      title: map['title'],
      location: map['location'],
      note: map['note'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      isAllDay: map['is_all_day'] == 1,
      reminder: map['reminder'],
      status: map['status'] ?? 'pending',
    );
  }
}
