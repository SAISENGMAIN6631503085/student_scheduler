import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/study_session.dart';
import '../models/subject.dart';

class StudyScheduleScreen extends StatefulWidget {
  const StudyScheduleScreen({super.key});

  @override
  State<StudyScheduleScreen> createState() => _StudyScheduleScreenState();
}

class _StudyScheduleScreenState extends State<StudyScheduleScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _durationMinutes = 60;
  Subject? _selectedSubject;
  final DateTime _firstDay = DateTime.now().subtract(const Duration(days: 365));
  final DateTime _lastDay = DateTime.now().add(const Duration(days: 365));

  @override
  Widget build(BuildContext context) {
    final storageService = context.watch<StorageService>();
    final subjects = storageService.getAllSubjects();
    final sessions = storageService.getStudySessionsByDate(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Schedule'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
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
                _buildAddSessionCard(subjects),
                const SizedBox(height: 16),
                _buildSessionsList(sessions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSessionCard(List<Subject> subjects) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Study Session',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Subject>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              items: subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Time'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Duration'),
              subtitle: Text('$_durationMinutes minutes'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_durationMinutes > 15) {
                        setState(() {
                          _durationMinutes -= 15;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _durationMinutes += 15;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSubject == null
                    ? null
                    : () => _addStudySession(context),
                child: const Text('Add Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList(List<StudySession> sessions) {
    final storageService = context.watch<StorageService>();
    final subjects = storageService.getAllSubjects();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scheduled Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (sessions.isEmpty)
              const Text('No study sessions scheduled for this day')
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
                          onChanged: (value) async {
                            session.isCompleted = value ?? false;
                            await storageService.updateStudySession(session);
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

  void _addStudySession(BuildContext context) {
    if (_selectedSubject == null) return;

    final storageService = context.read<StorageService>();
    final notificationService = context.read<NotificationService>();

    final session = StudySession.create(
      subjectId: _selectedSubject!.id,
      startTime: DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      durationMinutes: _durationMinutes,
    );

    storageService.addStudySession(session);
    notificationService.scheduleStudySessionNotification(session);

    // Clear form
    setState(() {
      _selectedSubject = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Study session added successfully'),
      ),
    );
  }
} 