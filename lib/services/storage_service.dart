import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/subject.dart';
import '../models/study_session.dart';
import '../models/exam.dart';

class StorageService {
  static const String subjectsBoxName = 'subjects';
  static const String studySessionsBoxName = 'study_sessions';
  static const String examsBoxName = 'exams';

  late Box<Subject> subjectsBox;
  late Box<StudySession> studySessionsBox;
  late Box<Exam> examsBox;

  Future<void> init() async {
    Hive.registerAdapter(SubjectAdapter());
    Hive.registerAdapter(StudySessionAdapter());
    Hive.registerAdapter(ExamAdapter());

    subjectsBox = await Hive.openBox<Subject>(subjectsBoxName);
    studySessionsBox = await Hive.openBox<StudySession>(studySessionsBoxName);
    examsBox = await Hive.openBox<Exam>(examsBoxName);
  }

  // Subject operations
  Future<void> addSubject(Subject subject) async {
    await subjectsBox.put(subject.id, subject);
  }

  Future<void> updateSubject(Subject subject) async {
    await subjectsBox.put(subject.id, subject);
  }

  Future<void> deleteSubject(String id) async {
    await subjectsBox.delete(id);
  }

  List<Subject> getAllSubjects() {
    return subjectsBox.values.toList();
  }

  // Study Session operations
  Future<void> addStudySession(StudySession session) async {
    await studySessionsBox.put(session.id, session);
  }

  Future<void> updateStudySession(StudySession session) async {
    await studySessionsBox.put(session.id, session);
  }

  Future<void> deleteStudySession(String id) async {
    await studySessionsBox.delete(id);
  }

  List<StudySession> getAllStudySessions() {
    return studySessionsBox.values.toList();
  }

  List<StudySession> getStudySessionsByDate(DateTime date) {
    return studySessionsBox.values.where((session) {
      return session.startTime.year == date.year &&
          session.startTime.month == date.month &&
          session.startTime.day == date.day;
    }).toList();
  }

  // Exam operations
  Future<void> addExam(Exam exam) async {
    await examsBox.put(exam.id, exam);
  }

  Future<void> updateExam(Exam exam) async {
    await examsBox.put(exam.id, exam);
  }

  Future<void> deleteExam(String id) async {
    await examsBox.delete(id);
  }

  List<Exam> getAllExams() {
    return examsBox.values.toList();
  }

  List<Exam> getUpcomingExams() {
    final now = DateTime.now();
    return examsBox.values
        .where((exam) => exam.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // Cleanup
  Future<void> close() async {
    await subjectsBox.close();
    await studySessionsBox.close();
    await examsBox.close();
  }
} 