// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExamAdapter extends TypeAdapter<Exam> {
  @override
  final int typeId = 2;

  @override
  Exam read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exam(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      dateTime: fields[2] as DateTime,
      durationMinutes: fields[3] as int,
      location: fields[4] as String?,
      notes: fields[5] as String?,
      isCompleted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Exam obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
