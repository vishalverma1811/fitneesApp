import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'model/workout_model.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> with SingleTickerProviderStateMixin {
  late Box<Workout> workoutBox;
  DateTime selectedDate = DateTime.now();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    workoutBox = Hive.box<Workout>('workouts');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward();
  }

  // Function to filter workouts based on selected date
  List<Workout> getWorkoutsByDate() {
    return workoutBox.values
        .where((workout) =>
    workout.date != null &&
        workout.date!.year == selectedDate.year &&
        workout.date!.month == selectedDate.month &&
        workout.date!.day == selectedDate.day)
        .toList();
  }

  // Function to show the DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Workout> workouts = getWorkoutsByDate();

    return Scaffold(
      appBar: AppBar(
        title: Text("Workout Chart"),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              _selectDate(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Expanded(
              child: CustomPaint(
                size: Size(double.infinity, 300),
                painter: BarChartPainter(workouts, _controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<Workout> workouts;
  final Animation<double> animation;
  final double barPadding = 16.0;

  BarChartPainter(this.workouts, this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final double maxValue = 100;
    final double chartHeight = size.height * 0.8;
    final double barWidth = (size.width - (barPadding * (workouts.length - 1))) / workouts.length;
    final Paint barPaint = Paint()..color = Colors.blue;
    final Paint axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    // Draw Y-axis and X-axis
    canvas.drawLine(Offset(0, chartHeight), Offset(size.width, chartHeight), axisPaint); // X-axis
    canvas.drawLine(Offset(0, 0), Offset(0, chartHeight), axisPaint); // Y-axis

    // Draw bars with padding and scale Y-axis height
    for (int i = 0; i < workouts.length; i++) {
      final workout = workouts[i];
      final barHeight = (workout.value / maxValue) * chartHeight * animation.value;

      final double xOffset = i * (barWidth + barPadding); // Add padding between bars
      final Rect barRect = Rect.fromLTWH(
        xOffset, // X position
        chartHeight - barHeight, // Y position
        barWidth, // Bar width
        barHeight, // Bar height
      );
      canvas.drawRect(barRect, barPaint);


      final textStyle = TextStyle(color: Colors.black, fontSize: 10);
      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.text = TextSpan(text: workout.name, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xOffset + (barWidth / 2) - textPainter.width / 2, chartHeight + 4),
      );
    }


    final textStyle = TextStyle(color: Colors.black, fontSize: 12);
    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );


    for (int i = 0; i <= maxValue; i += 25) {
      final label = TextSpan(text: '$i', style: textStyle);
      textPainter.text = label;
      textPainter.layout();
      textPainter.paint(canvas, Offset(-30, chartHeight - (i / maxValue) * chartHeight - 8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
