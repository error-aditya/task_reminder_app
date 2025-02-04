import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String priority;

  @HiveField(3)
  bool status;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  DateTime alertDate;

  @HiveField(6)
  String userId;

  @HiveField(7)
  double? latitude;

  @HiveField(8)
  double? longitude;

  @HiveField(9)
  double? radius;

  Task({
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.date,
    required this.alertDate,
    required this.userId,
    this.latitude,
    this.longitude,
    this.radius,
  });

  void save() {
    Hive.box<Task>('taskk').put(title, this);
  }

  @override
  String toString() {
    return 'Task(title: $title, description: $description, priority: $priority, status: $status, date: $date, alertDate: $alertDate)';
  }

  set setTitle(String value) {
    title = value;
  }

  set setDescription(String value) {
    description = value;
  }

  set setPriority(String value) {
    priority = value;
  }

  set setAlertDate(DateTime value) {
    alertDate = value;
  }

  set setLatitude(double? value) {
    latitude = value;
  }

  set setLongitude(double? value) {
    longitude = value;
  }

  set setRadius(double? value) {
    radius = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'date': date,
      'alertDate': alertDate,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }
}
