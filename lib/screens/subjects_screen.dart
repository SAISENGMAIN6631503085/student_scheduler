import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/subject.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _selectedIconCode = Icons.school.codePoint;

  final List<IconData> _icons = [
    Icons.school, // School
    Icons.science, // Science
    Icons.calculate, // Math
    Icons.language, // Language
    Icons.history_edu, // History
    Icons.psychology, // Psychology
    Icons.biotech, // Biology
    Icons.architecture, // Architecture
    Icons.music_note, // Music
    Icons.sports_soccer, // Sports
    Icons.computer, // Computer Science
    Icons.brush, // Art
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storageService = context.watch<StorageService>();
    final subjects = storageService.getAllSubjects();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(IconData(subject.effectiveIconCode, fontFamily: 'MaterialIcons')),
              ),
              title: Text(subject.name),
              subtitle: subject.description != null
                  ? Text(subject.description!)
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(context, subject),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteDialog(context, subject),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    _nameController.clear();
    _descriptionController.clear();
    _selectedIconCode = Icons.school.codePoint;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Subject'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose an icon for your subject:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _icons.map((icon) {
                    final isSelected = _selectedIconCode == icon.codePoint;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          _selectedIconCode = icon.codePoint;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  final subject = Subject.create(
                    name: _nameController.text,
                    description: _descriptionController.text.isEmpty
                        ? null
                        : _descriptionController.text,
                    color: '#2196F3',
                    iconCode: _selectedIconCode ?? Icons.school.codePoint,
                  );
                  context.read<StorageService>().addSubject(subject);
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subject added successfully'),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Subject subject) {
    _nameController.text = subject.name;
    _descriptionController.text = subject.description ?? '';
    _selectedIconCode = subject.iconCode ?? Icons.school.codePoint;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Subject'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose an icon for your subject:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _icons.map((icon) {
                    final isSelected = _selectedIconCode == icon.codePoint;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          _selectedIconCode = icon.codePoint;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  subject.name = _nameController.text;
                  subject.description = _descriptionController.text.isEmpty
                      ? null
                      : _descriptionController.text;
                  subject.iconCode = _selectedIconCode;
                  context.read<StorageService>().updateSubject(subject);
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subject updated successfully'),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subject.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<StorageService>().deleteSubject(subject.id);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${subject.name} deleted successfully'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 