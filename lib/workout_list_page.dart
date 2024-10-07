import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'model/workout_model.dart';

class WorkoutListPage extends StatefulWidget {
  @override
  _WorkoutListPageState createState() => _WorkoutListPageState();
}

class _WorkoutListPageState extends State<WorkoutListPage> {
  late Box<Workout> workoutBox;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    workoutBox = Hive.box<Workout>('workouts');
  }

  // Function to mark workout as done
  void markDone(int index, Workout workout) {
    setState(() {
      workout.done = true;
      workoutBox.putAt(index, workout);
    });
  }

  // Function to show the DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Function to filter workouts by selected date
  List<Workout> _getFilteredWorkouts() {
    if (selectedDate == null) {
      return workoutBox.values.toList();
    } else {
      return workoutBox.values
          .where((workout) =>
      workout.date != null &&
          workout.date!.year == selectedDate!.year &&
          workout.date!.month == selectedDate!.month &&
          workout.date!.day == selectedDate!.day)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Workout> filteredWorkouts = _getFilteredWorkouts();

    return Scaffold(
      appBar: AppBar(
        title: Text('Workout List'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              _selectDate(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredWorkouts.length,
              itemBuilder: (context, index) {
                Workout workout = filteredWorkouts[index];
                return ListTile(
                  title: Text(workout.name),
                  subtitle: Text(
                    "Value: ${workout.value}, Date: ${workout.date.toString().split(' ')[0]}",
                  ),
                  trailing: workout.done
                      ? Text("Done")
                      : ElevatedButton(
                    onPressed: () {
                      markDone(index, workout);
                    },
                    child: Text("Mark Done"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
