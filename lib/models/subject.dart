import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 0)
class Subject extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String color;

  @HiveField(4)
  int? iconCode;

  int get effectiveIconCode => iconCode ?? Icons.school.codePoint;

  Subject({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    this.iconCode,
  });

  factory Subject.create({
    required String name,
    String? description,
    required String color,
    required int iconCode,
  }) {
    return Subject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      color: color,
      iconCode: iconCode,
    );
  }
} 