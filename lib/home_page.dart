import 'package:fitnees_app/workout_list_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'chart_page.dart';
import 'model/workout_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var workoutBox = Hive.box<Workout>('workouts');
  TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    workoutBox = Hive.box<Workout>('workouts');
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // Function to mark a workout as done and assign a value
  void markDone(Workout workout, int value) {
    setState(() {
      workout.done = true;
      workout.value = value;
      workout.date = DateTime.now();
    });
  }

  // Function to show a dialog to add a new workout
  void addWorkoutDialog() {
    String workoutName = "";
    DateTime selectedDate = DateTime.now();
    bool isDone = false;
    int userValue = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Workout"),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: "Enter Workout Name"),
                    onChanged: (value) {
                      workoutName = value;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Select Date",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                          _dateController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Mark as Done:"),
                      Checkbox(
                        value: isDone,
                        onChanged: (value) {
                          setState(() {
                            isDone = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Enter Value (0-100)",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      userValue = int.parse(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (workoutName.isNotEmpty) {
                  // Add new workout with the input data
                  Workout newWorkout = Workout(
                    name: workoutName,
                    done: isDone,
                    value: isDone ? userValue : 0,
                    date: selectedDate,
                  );
                  workoutBox.add(newWorkout);
                }
                Navigator.of(context).pop();
              },
              child: Text("Add Workout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout List'),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WorkoutListPage()),  // Navigate to the workout list page
                  );
                },
                icon: Icon(Icons.list),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChartPage()),  // Navigate to the chart page
                  );
                },
                icon: Icon(Icons.bar_chart),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: workoutBox.listenable(),
              builder: (context, Box<Workout> box, _) {
                if (box.values.isEmpty) {
                  return Center(
                    child: Text('No workouts added yet'),
                  );
                }
                return ListView.builder(
                  itemCount: box.values.length,
                  itemBuilder: (context, index) {
                    Workout workout = box.getAt(index)!;
                    return ListTile(
                      title: Text(workout.name),
                      subtitle: Text(workout.done
                          ? 'Done on ${workout.date.toString().split(" ")[0]}'
                          : 'Not Done'),
                      trailing: workout.done
                          ? Text("Value: ${workout.value.toString()}")
                          : ElevatedButton(
                        onPressed: () {
                          // Mark workout as done and assign value
                          showDialog(
                            context: context,
                            builder: (context) {
                              int userValue = 0;
                              return AlertDialog(
                                title: Text("Enter Value (0-100)"),
                                content: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    userValue = int.parse(value);
                                  },
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      markDone(workout, userValue);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Mark Done"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Mark Done'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addWorkoutDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
