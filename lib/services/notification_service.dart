import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/study_session.dart';
import '../models/exam.dart';
import '../models/subject.dart';
import '../services/storage_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  late StorageService _storageService;

  Future<void> init(StorageService storageService) async {
    _storageService = storageService;
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleStudySessionNotification(StudySession session) async {
    final tzDateTime = tz.TZDateTime.from(session.startTime, tz.local);
    final subject = _storageService.getAllSubjects().firstWhere(
      (s) => s.id == session.subjectId,
      orElse: () => Subject(
        id: session.subjectId,
        name: 'Unknown Subject',
        color: '#2196F3',
        iconCode: Icons.school.codePoint,
      ),
    );
    
    await _notifications.zonedSchedule(
      session.hashCode,
      'Study Session Reminder',
      'Time to study ${subject.name}',
      tzDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'study_sessions',
          'Study Sessions',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(int.parse(subject.color.replaceAll('#', '0xFF'))),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleExamNotification(Exam exam) async {
    final tzDateTime = tz.TZDateTime.from(exam.dateTime, tz.local);
    final subject = _storageService.getAllSubjects().firstWhere(
      (s) => s.id == exam.subjectId,
      orElse: () => Subject(
        id: exam.subjectId,
        name: 'Unknown Subject',
        color: '#2196F3',
        iconCode: Icons.school.codePoint,
      ),
    );
    
    await _notifications.zonedSchedule(
      exam.hashCode,
      'Exam Reminder',
      'Upcoming exam: ${subject.name}',
      tzDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'exams',
          'Exams',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(int.parse(subject.color.replaceAll('#', '0xFF'))),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 