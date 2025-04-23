import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/exam.dart';
import '../models/subject.dart';

class ExamScheduleScreen extends StatefulWidget {
  const ExamScheduleScreen({super.key});

  @override
  State<ExamScheduleScreen> createState() => _ExamScheduleScreenState();
}

class _ExamScheduleScreenState extends State<ExamScheduleScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _durationMinutes = 120;
  Subject? _selectedSubject;
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final DateTime _firstDay = DateTime.now().subtract(const Duration(days: 365));
  final DateTime _lastDay = DateTime.now().add(const Duration(days: 365));

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storageService = context.watch<StorageService>();
    final subjects = storageService.getAllSubjects();
    final exams = storageService.getAllExams();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Schedule'),
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
                _buildAddExamCard(subjects),
                const SizedBox(height: 16),
                _buildExamsList(exams),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddExamCard(List<Subject> subjects) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Exam',
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
                      if (_durationMinutes > 30) {
                        setState(() {
                          _durationMinutes -= 30;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _durationMinutes += 30;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSubject == null
                    ? null
                    : () => _addExam(context),
                child: const Text('Add Exam'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamsList(List<Exam> exams) {
    final storageService = context.watch<StorageService>();
    final subjects = storageService.getAllSubjects();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scheduled Exams',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (exams.isEmpty)
              const Text('No exams scheduled')
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

  void _addExam(BuildContext context) {
    if (_selectedSubject == null) return;

    final storageService = context.read<StorageService>();
    final notificationService = context.read<NotificationService>();

    final exam = Exam.create(
      subjectId: _selectedSubject!.id,
      dateTime: DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      durationMinutes: _durationMinutes,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    storageService.addExam(exam);
    notificationService.scheduleExamNotification(exam);

    // Clear form
    setState(() {
      _selectedSubject = null;
      _locationController.clear();
      _notesController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exam added successfully'),
      ),
    );
  }
} 