import 'package:flutter/material.dart';
import 'package:time_picker_spinner/time_picker_spinner.dart';
import '../layout/main_layout.dart';
import '../models/medicine_mod.dart';
import '../db/database.dart';
import 'package:shared_preferences/shared_preferences.dart';




class TakeMedicinePage extends StatefulWidget {
  @override
  _TakeMedicinePageState createState() => _TakeMedicinePageState();
}

class _TakeMedicinePageState extends State<TakeMedicinePage> {
  TextEditingController medicineController = TextEditingController();
  TextEditingController amountController = TextEditingController(text: "10");
  TextEditingController timesPerDayController = TextEditingController(text: "2");
  TextEditingController noteController = TextEditingController();

  String selectedMealTime = ""; // 'breakfast', 'lunch', etc.
  String mealRelation = ""; // 'before' or 'after'
  Map<String, TimeOfDay> mealTimes = {
  "breakfast": TimeOfDay(hour: 9, minute: 0),
  "lunch": TimeOfDay(hour: 12, minute: 0),
  "dinner": TimeOfDay(hour: 18, minute: 0),
  "bedtime": TimeOfDay(hour: 22, minute: 0),
  }; 

  String? activeTimeEdit; // กำลังแก้เวลาไหน
  String reminder = "1 hour before";
  
  Set<String> selectedMealTimes = {};

  void selectMealTime(String time) {
  setState(() {
    if (selectedMealTimes.contains(time)) {
      selectedMealTimes.remove(time);
    } else {
      selectedMealTimes.add(time);
    }
  });
}

  void selectMealRelation(String value) {
    setState(() {
      mealRelation = value;
    });
  }

  void _onSave() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId') ?? 0;

  final now = DateTime.now();
  final defaultTimes = {
    "breakfast": "09:00 AM",
    "lunch": "12:00 PM",
    "dinner": "06:00 PM",
    "bedtime": "10:00 PM",
  };

  final timeStrings = {
    for (var time in selectedMealTimes)
      time: defaultTimes[time]!,
  };

  final medicine = MedicineModel(
    userId: userId,
    name: medicineController.text,
    amount: int.tryParse(amountController.text) ?? 0,
    timesPerDay: int.tryParse(timesPerDayController.text) ?? 0,
    timeSlots: selectedMealTimes.toList(),
    timeStrings: timeStrings,
    relation: mealRelation,
    note: noteController.text,
    reminder: reminder,
    date: DateTime(now.year, now.month, now.day),
  );

  await DatabaseHelper().insertMedicine(medicine, userId);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Medicine Saved!")),
  );

  Navigator.pop(context);
}


  void _onCancel() {
    Navigator.pop(context);
  }

  Widget buildMealTimePicker() {
  final mealLabels = {
    "breakfast": "Breakfast",
    "lunch": "Lunch",
    "dinner": "Dinner",
    "bedtime": "Bedtime",
  };

  return Column(
    children: selectedMealTimes.map((key) {
      final label = mealLabels[key]!;
      final time = mealTimes[key]!;
      final formatted = time.format(context);

      return ListTile(
        title: Text(label),
        trailing: Text(formatted, style: TextStyle(color: Colors.grey[700])),
        onTap: () {
          setState(() {
            activeTimeEdit = key;
          });
        },
      );
    }).toList(),
  );
}

Widget buildTimeSelector() {
  if (activeTimeEdit == null) return SizedBox();

  final time = mealTimes[activeTimeEdit!]!;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: TimePickerSpinner(
      is24HourMode: false,
      normalTextStyle: TextStyle(fontSize: 18, color: Colors.grey),
      highlightedTextStyle: TextStyle(fontSize: 22, color: Colors.black),
      spacing: 30,
      itemHeight: 40,
      isForce2Digits: true,
      time: DateTime(2020, 1, 1, time.hour, time.minute), // ✅ ป้องกัน error
      onTimeChange: (newTime) {
        setState(() {
          mealTimes[activeTimeEdit!] =
              TimeOfDay(hour: newTime.hour, minute: newTime.minute);
        });
      },
    ),
  );
}


  Widget buildIconButton(String label, IconData icon, String value) {
  bool isSelected = selectedMealTimes.contains(value);

  // Map สีของแต่ละช่วงเวลา
  final Map<String, Color> timeColors = {
    "breakfast": Colors.yellow,
    "lunch": Colors.orange,
    "dinner": Colors.blue,
    "bedtime": Colors.purple,
  };

  return GestureDetector(
    onTap: () => selectMealTime(value),
    child: Column(
      children: [
        CircleAvatar(
          backgroundColor: isSelected ? timeColors[value]! : Colors.grey.shade300,
          child: Icon(icon, color: isSelected ? Colors.white : Colors.black),
        ),
        SizedBox(height: 5),
        Text(label),
      ],
    ),
  );
  
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
                      Text("Take Medicine",
                          style: TextStyle(color: Colors.white, fontSize: 22)),
                      Icon(Icons.notifications, color: Colors.white),
                    ],
                  ),
                ),
              ),
              Expanded(
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
                        TextField(
                          controller: medicineController,
                          decoration: InputDecoration(
                            hintText: "Add Your Medicine"
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Amount (Tablet)",
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: timesPerDayController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Times Per Day",
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildIconButton("Breakfast", Icons.wb_twighlight, "breakfast"),
                            buildIconButton("Lunch", Icons.wb_sunny, "lunch"),
                            buildIconButton("Dinner", Icons.wb_cloudy, "dinner"),
                            buildIconButton("Bedtime", Icons.nightlight_round, "bedtime"),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Radio<String>(
                                  value: "before",
                                  groupValue: mealRelation,
                                  onChanged: (value) {
                                    if (value != null) selectMealRelation(value);
                                  },
                                ),
                                Text("Before meal"),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  value: "after",
                                  groupValue: mealRelation,
                                  onChanged: (value) {
                                    if (value != null) selectMealRelation(value);
                                  },
                                ),
                                Text("After meal"),
                              ],
                            ),
                          ],
                        ),

                        if (mealRelation.isNotEmpty) ...[
                          Divider(),
                          buildMealTimePicker(),
                          buildTimeSelector(),
                        ],
                        Divider(),
                          Row(
                          children: [
                            Icon(Icons.notifications_active_outlined),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _showReminderOptions(),
                              child: Row(
                                children: [
                                  Text(reminder, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Icon(Icons.keyboard_arrow_down),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Divider(),
                        TextField(
                          controller: noteController,
                          maxLines: 1,
                          decoration: InputDecoration(
                            icon: Icon(Icons.note_alt_outlined),
                            hintText: "Note",
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: _onCancel,
                              child: Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 18)),
                            ),
                            TextButton(
                              onPressed: _onSave,
                              child: Text("Save", style: TextStyle(color: Colors.green, fontSize: 18)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

void _showReminderOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = [
          "30 minutes before",
          "1 hour before",
          "2 hours before",
          "5 hours before",
          "12 hours before",
          "1 day before",
          "3 days before",
          "1 week before",
        ];

        return ListView(
          shrinkWrap: true,
          children: options.map((option) {
            return ListTile(
              title: Text(option),
              trailing: reminder == option ? Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                setState(() {
                  reminder = option;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

}