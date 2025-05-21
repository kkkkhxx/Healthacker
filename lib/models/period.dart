class PeriodModel {
  final int? id;
  final int userId;
  final DateTime date;
  final String volume;
  final String mood;
  final String symptom;
  final String sexDrive;

  PeriodModel({
    this.id,
    required this.userId,
    required this.date,
    required this.volume,
    required this.mood,
    required this.symptom,
    required this.sexDrive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'volume': volume,
      'mood': mood,
      'symptom': symptom,
      'sex_drive': sexDrive,
    };
  }

  factory PeriodModel.fromMap(Map<String, dynamic> map) {
    return PeriodModel(
      id: map['id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      volume: map['volume'],
      mood: map['mood'],
      symptom: map['symptom'],
      sexDrive: map['sex_drive'],
    );
  }
}
