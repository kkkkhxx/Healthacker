import 'dart:convert';

class MedicineModel {
  final int? id;
  final int userId;
  final String name;
  final int amount;
  final int timesPerDay;
  final List<String> timeSlots;
  final Map<String, String> timeStrings;
  final String relation;
  final String note;
  final String reminder;
  final DateTime date;
  final String status;

  MedicineModel({
    this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.timesPerDay,
    required this.timeSlots,
    required this.timeStrings,
    required this.relation,
    required this.note,
    required this.reminder,
    required this.date,
    this.status = 'pending',
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      amount: map['amount'],
      timesPerDay: map['times_per_day'],
      timeSlots: (map['time_slots'] as String).split(','),
      timeStrings: Map<String, String>.from(
        map.containsKey('time_strings')
            ? Map<String, dynamic>.from(jsonDecode(map['time_strings']))
            : {},
      ),
      relation: map['relation'],
      note: map['note'],
      reminder: map['reminder'],
      date: DateTime.parse(map['date']),
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'amount': amount,
      'times_per_day': timesPerDay,
      'time_slots': timeSlots.join(','),
      'time_strings': jsonEncode(timeStrings),
      'relation': relation,
      'note': note,
      'reminder': reminder,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
