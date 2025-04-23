import 'package:hive/hive.dart';

part 'study_session.g.dart';

@HiveType(typeId: 1)
class StudySession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  DateTime startTime;

  @HiveField(3)
  int durationMinutes;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  String? examId;

  StudySession({
    required this.id,
    required this.subjectId,
    required this.startTime,
    required this.durationMinutes,
    this.isCompleted = false,
    this.notes,
    this.examId,
  });

  factory StudySession.create({
    required String subjectId,
    required DateTime startTime,
    required int durationMinutes,
    String? notes,
    String? examId,
  }) {
    return StudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subjectId: subjectId,
      startTime: startTime,
      durationMinutes: durationMinutes,
      notes: notes,
      examId: examId,
    );
  }

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));
} 