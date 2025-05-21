import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/period.dart';
import '../db/database.dart';

class Addmonthlyperiod extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PeriodTracker();
  }
}

class PeriodTracker extends StatefulWidget {
  @override
  _PeriodTrackerState createState() => _PeriodTrackerState();
}

class _PeriodTrackerState extends State<PeriodTracker> {
  DateTime selectedDate = DateTime.now();
  String volume = '';
  String mood = '';
  String symptom = '';
  String sexDrive = '';
  int? userId;

  void selectDay(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    loadPeriodData(date); // โหลดข้อมูลจากฐานข้อมูล
  }

  void cancelData(BuildContext context) {
    Navigator.pop(context);
  }

  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    if (userId == null) return;

    final period = PeriodModel(
      userId: userId!,
      date: selectedDate,
      volume: volume,
      mood: mood,
      symptom: symptom,
      sexDrive: sexDrive,
    );

    await DatabaseHelper().insertPeriod(period, userId!);
    await prefs.setString('last_period_date', selectedDate.toIso8601String());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Saved Period")),
    );

    Navigator.pop(context);
  }

  void loadPeriodData(DateTime date) async {
    if (userId == null) return;
    final db = DatabaseHelper();
    final period = await db.getPeriodByDate(userId!, date);

    if (period != null) {
      setState(() {
        volume = period.volume;
        mood = period.mood;
        symptom = period.symptom;
        sexDrive = period.sexDrive;
      });
    } else {
      setState(() {
        volume = '';
        mood = '';
        symptom = '';
        sexDrive = '';
      });
    }
  }

  Widget buildChoice(String selected, String value, Function(String) onSelect) {
    return GestureDetector(
      onTap: () {
        setState(() {
          onSelect(value);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: (selected == value)
              ? const Color.fromARGB(255, 98, 52, 222)
              : const Color.fromARGB(255, 234, 234, 234),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: (selected == value) ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    if (userId != null) {
      loadPeriodData(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF003765), Color(0xFF539CE4)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Add Period", style: TextStyle(color: Colors.white, fontSize: 22)),
                      Icon(Icons.notifications, color: Colors.white),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! < 0) {
                      selectDay(selectedDate.add(Duration(days: 1)));
                    } else if (details.primaryVelocity! > 0) {
                      selectDay(selectedDate.subtract(Duration(days: 1)));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('EEEE, dd MMM yyyy').format(selectedDate),
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(7, (index) {
                                    DateTime date = selectedDate.subtract(Duration(days: 3 - index));
                                    bool isSelected = date.day == selectedDate.day &&
                                        date.month == selectedDate.month &&
                                        date.year == selectedDate.year;
                                    return GestureDetector(
                                      onTap: () => selectDay(date),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected ? Color(0xFFFF7F9F) : Colors.grey.shade200,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${date.day}',
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 40),
                          Text('Volume', style: TextStyle(fontSize: 16)),
                          Wrap(
                            children: [
                              buildChoice(volume, 'Heavy', (val) => volume = val),
                              buildChoice(volume, 'Medium', (val) => volume = val),
                              buildChoice(volume, 'Light', (val) => volume = val),
                              buildChoice(volume, 'Spotting', (val) => volume = val),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text('Mood', style: TextStyle(fontSize: 16)),
                          Wrap(
                            children: [
                              buildChoice(mood, 'Happy', (val) => mood = val),
                              buildChoice(mood, 'Energetic', (val) => mood = val),
                              buildChoice(mood, 'Calm', (val) => mood = val),
                              buildChoice(mood, 'Swing', (val) => mood = val),
                              buildChoice(mood, 'Bad', (val) => mood = val),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text('Symptoms', style: TextStyle(fontSize: 16)),
                          Wrap(
                            children: [
                              buildChoice(symptom, 'Fine', (val) => symptom = val),
                              buildChoice(symptom, 'Cramps', (val) => symptom = val),
                              buildChoice(symptom, 'Headache', (val) => symptom = val),
                              buildChoice(symptom, 'Acne', (val) => symptom = val),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text('Sex Drive', style: TextStyle(fontSize: 16)),
                          Wrap(
                            children: [
                              buildChoice(sexDrive, 'Didn’t Have Sex', (val) => sexDrive = val),
                              buildChoice(sexDrive, 'Masturbation', (val) => sexDrive = val),
                              buildChoice(sexDrive, 'Protected Sex', (val) => sexDrive = val),
                              buildChoice(sexDrive, 'Unprotected Sex', (val) => sexDrive = val),
                            ],
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () => cancelData(context),
                                child: Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 18)),
                              ),
                              TextButton(
                                onPressed: saveData,
                                child: Text("Save", style: TextStyle(color: Colors.green, fontSize: 18)),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
