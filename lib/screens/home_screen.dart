import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/storage_service.dart';
import '../models/study_session.dart';
import '../models/exam.dart';
import '../models/subject.dart';
import '../widgets/quote_card.dart';
import 'study_schedule_screen.dart';
import 'exam_schedule_screen.dart';
import 'subjects_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final DateTime _firstDay = DateTime.now().subtract(const Duration(days: 365));
  final DateTime _lastDay = DateTime.now().add(const Duration(days: 365));
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final storageService = context.watch<StorageService>();
    List<StudySession> todaySessions = [];
    List<Exam> upcomingExams = [];

    try {
      todaySessions = storageService.getStudySessionsByDate(_selectedDay);
      upcomingExams = storageService.getUpcomingExams();
    } catch (e) {
      // Handle initialization state
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Scheduler'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubjectsScreen(),
                    ),
                  ).then((_) {
                    // Refresh the screen when returning from subjects screen
                    setState(() {});
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const QuoteCard(),
                const SizedBox(height: 16),
                _buildTodaySection(todaySessions),
                const SizedBox(height: 16),
                _buildUpcomingExamsSection(upcomingExams),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Study',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Exams',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudyScheduleScreen(),
              ),
            ).then((_) {
              setState(() {});
            });
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExamScheduleScreen(),
              ),
            ).then((_) {
              setState(() {});
            });
          }
        },
      ),
    );
  }

  Widget _buildTodaySection(List<StudySession> sessions) {
    final storageService = context.watch<StorageService>();
    final subjects = storageService.getAllSubjects();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Study Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (sessions.isEmpty)
              const Text('No study sessions scheduled for today')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final subject = subjects.firstWhere(
                    (s) => s.id == session.subjectId,
                    orElse: () => Subject(
                      id: session.subjectId,
                      name: 'Unknown Subject',
                      color: '#2196F3',
                      iconCode: Icons.school.codePoint,
                    ),
                  );
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(int.parse(subject.color.replaceAll('#', '0xFF'))),
                      child: Icon(IconData(subject.effectiveIconCode, fontFamily: 'MaterialIcons')),
                    ),
                    title: Text(subject.name),
                    subtitle: Text(
                      '${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')} - ${session.durationMinutes} minutes',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: session.isCompleted,
                          onChanged: (value) {
                            session.isCompleted = value ?? false;
                            storageService.updateStudySession(session);
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Study Session'),
                                content: Text('Are you sure you want to delete this study session?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await storageService.deleteStudySession(session.id);
                                      Navigator.pop(context);
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Study session deleted successfully'),
                                        ),
                                      );
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingExamsSection(List<Exam> exams) {
    final storageService = context.watch<StorageService>();
    final subjects = storageService.getAllSubjects();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Exams',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (exams.isEmpty)
              const Text('No upcoming exams')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  final subject = subjects.firstWhere(
                    (s) => s.id == exam.subjectId,
                    orElse: () => Subject(
                      id: exam.subjectId,
                      name: 'Unknown Subject',
                      color: '#2196F3',
                      iconCode: Icons.school.codePoint,
                    ),
                  );
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(int.parse(subject.color.replaceAll('#', '0xFF'))),
                      child: Icon(IconData(subject.effectiveIconCode, fontFamily: 'MaterialIcons')),
                    ),
                    title: Text(subject.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${exam.dateTime.day}/${exam.dateTime.month}/${exam.dateTime.year} at ${exam.dateTime.hour}:${exam.dateTime.minute.toString().padLeft(2, '0')}',
                        ),
                        if (exam.location != null)
                          Text('Location: ${exam.location}'),
                        if (exam.notes != null) Text('Notes: ${exam.notes}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: exam.isCompleted,
                          onChanged: (value) {
                            exam.isCompleted = value ?? false;
                            storageService.updateExam(exam);
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Exam'),
                                content: Text('Are you sure you want to delete this exam?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await storageService.deleteExam(exam.id);
                                      Navigator.pop(context);
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Exam deleted successfully'),
                                        ),
                                      );
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
} 