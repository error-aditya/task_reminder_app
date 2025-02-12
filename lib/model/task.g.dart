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
      title: fields[0] as String? ?? "", // Default empty string if null
      description: fields[1] as String? ?? "",
      priority: fields[2] as String? ?? "Low", // Default priority
      status: fields[3] as bool? ?? false, // Default false if null
      date: fields[4] as DateTime? ?? DateTime.now(),
      alertDate: fields[5] as DateTime? ?? DateTime.now(),
      userId: fields[6] is String ? fields[6] as String : "unknown",
      latitude: fields[7] as double?, // Nullable
      longitude: fields[8] as double?, // Nullable
      radius: fields[9] as double?, // Nullable
      address: fields[10] is String ? fields[10] as String : "",
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
