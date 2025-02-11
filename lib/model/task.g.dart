// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      title: fields[0] is String ? fields[0] as String : '', // ✅ Safe parsing
      description: fields[1] is String ? fields[1] as String : '',
      priority: fields[2] is String ? fields[2] as String : 'low',
      status: fields[3] is bool ? fields[3] as bool : false, // ✅ Safe parsing
      date: fields[4] is DateTime ? fields[4] as DateTime : DateTime.now(),
      alertDate: fields[5] is DateTime ? fields[5] as DateTime : DateTime.now(),
      userId: fields[6] is String ? fields[6] as String : '',
      latitude: fields[7] is double? ? fields[7] as double? : null,
      longitude: fields[8] is double? ? fields[8] as double? : null,
      radius: fields[9] is double? ? fields[9] as double? : null,
      address:
          fields[10] is String ? fields[10] as String : '', // ✅ Safe parsing
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.priority)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.alertDate)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.latitude)
      ..writeByte(8)
      ..write(obj.longitude)
      ..writeByte(9)
      ..write(obj.radius)
      ..writeByte(10)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
