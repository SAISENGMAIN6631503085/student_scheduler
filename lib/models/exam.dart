import 'package:hive/hive.dart';

part 'exam.g.dart';

@HiveType(typeId: 2)
class Exam extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  DateTime dateTime;

  @HiveField(3)
  int durationMinutes;

  @HiveField(4)
  String? location;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  bool isCompleted;

  Exam({
    required this.id,
    required this.subjectId,
    required this.dateTime,
    required this.durationMinutes,
    this.location,
    this.notes,
    this.isCompleted = false,
  });

  factory Exam.create({
    required String subjectId,
    required DateTime dateTime,
    required int durationMinutes,
    String? location,
    String? notes,
  }) {
    return Exam(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subjectId: subjectId,
      dateTime: dateTime,
      durationMinutes: durationMinutes,
      location: location,
      notes: notes,
    );
  }

  DateTime get endTime => dateTime.add(Duration(minutes: durationMinutes));
} 