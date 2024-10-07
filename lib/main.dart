import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'home_page.dart';
import 'model/workout_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  // Register Workout Adapter
  Hive.registerAdapter(WorkoutAdapter());

  await Hive.openBox<Workout>('workouts');

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF3AA8C1)),
        useMaterial3: true,
      ),
      home:  HomePage(),
    );
  }
}
