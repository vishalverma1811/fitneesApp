import 'package:hive/hive.dart';

part 'workout_model.g.dart';

@HiveType(typeId: 0)
class Workout {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool done;

  @HiveField(2)
  int value; // Value from 0-100

  @HiveField(3)
  DateTime date;

  Workout({required this.name, required this.done, required this.value, required this.date});
}
