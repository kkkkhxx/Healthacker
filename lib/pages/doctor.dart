import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../layout/main_layout.dart';
import '../service/api_map.dart';
import '../models/appointment.dart';
import '../db/database.dart';

class DoctorAppointmentPage extends StatefulWidget {
  @override
  _DoctorAppointmentPageState createState() => _DoctorAppointmentPageState();
}

class _DoctorAppointmentPageState extends State<DoctorAppointmentPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  List<String> locationSuggestions = [];
  bool isAllDay = false;
  TimeOfDay startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 10, minute: 0);
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String reminder = "1 hour before";

  @override
  void initState() {
    super.initState();
    locationController.addListener(() async {
      final query = locationController.text;
      if (query.length >= 3) {
        try {
          final results = await TomTomService.searchLocations(query);
          setState(() {
            locationSuggestions = results;
          });
        } catch (e) {
          print("Error fetching locations: \$e");
        }
      }
    });
  }

  void _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _onSave() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;

    final startDT = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );
    final endDT = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    final appointment = AppointmentModel(
      title: titleController.text,
      location: locationController.text,
      note: noteController.text,
      startTime: startDT,
      endTime: endDT,
      isAllDay: isAllDay,
      reminder: reminder,
    );

    await DatabaseHelper().insertAppointment(appointment, userId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Appointment saved")),
    );

    Navigator.pop(context);
  }

  void _onCancel() {
    Navigator.pop(context);
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
                      Text("Doctor's Appointment", style: TextStyle(color: Colors.white, fontSize: 22)),
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
                      children: [
                        TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.access_time),
                            SizedBox(width: 5),
                            Text("All day"),
                            Spacer(),
                            Switch(value: isAllDay, onChanged: (value) => setState(() => isAllDay = value)),
                          ],
                        ),
                        if (!isAllDay) ...[
                          _buildDateTimePicker("Start", true),
                          _buildDateTimePicker("End", false),
                        ],
                        Divider(),
                        TextField(controller: locationController, decoration: InputDecoration(icon: Icon(Icons.location_on), hintText: "Location")),
                        if (locationSuggestions.isNotEmpty)
                          Column(
                            children: locationSuggestions.map((s) => ListTile(
                              title: Text(s),
                              onTap: () => setState(() => locationController.text = s),
                            )).toList(),
                          ),
                        Divider(),
                        _buildReminderPicker(),
                        Divider(),
                        TextField(controller: noteController, maxLines: 1, decoration: InputDecoration(icon: Icon(Icons.note_alt_outlined), hintText: "Note")),
                        SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(onPressed: _onCancel, child: Text("Cancel", style: TextStyle(color: Colors.red, fontSize: 18))),
                            TextButton(onPressed: _onSave, child: Text("Save", style: TextStyle(color: Colors.green, fontSize: 18))),
                          ],
                        ),
                      ],
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

  Widget _buildDateTimePicker(String label, bool isStart) {
    final date = isStart ? startDate : endDate;
    final time = isStart ? startTime : endTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _pickDate(isStart: isStart),
              child: Text(DateFormat('y-MM-dd').format(date)),
            ),
            TextButton(
              onPressed: () => _pickTime(isStart: isStart),
              child: Text(time.format(context)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildReminderPicker() {
    return Row(
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
          children: options.map((option) => ListTile(
            title: Text(option),
            trailing: reminder == option ? Icon(Icons.check, color: Colors.blue) : null,
            onTap: () {
              setState(() => reminder = option);
              Navigator.pop(context);
            },
          )).toList(),
        );
      },
    );
  }
} 
