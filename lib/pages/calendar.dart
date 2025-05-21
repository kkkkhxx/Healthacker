import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import '../models/medicine_mod.dart';
import '../db/database.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  List<AppointmentModel> allAppointments = [];
  List<AppointmentModel> filteredAppointments = [];
  List<MedicineModel> _medicines = [];

  int? userId;

  @override
  void initState() {
    super.initState();
    selectedDay = focusedDay;
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    if (userId != null) {
      await _loadAppointments();
      await _loadMedicines();
    }
  }

  Future<void> _loadAppointments() async {
    if (userId == null) return;
    final data = await DatabaseHelper().getAppointmentsByUser(userId!);
    setState(() {
      allAppointments = data;
      _filterAppointments();
    });
  }

  Future<void> _loadMedicines() async {
    if (userId == null) return;
    final data = await DatabaseHelper().getAllMedicines(userId!);
    setState(() {
      _medicines = data.where((m) =>
        m.date.year == selectedDay!.year &&
        m.date.month == selectedDay!.month &&
        m.date.day == selectedDay!.day
      ).toList();
    });
  }

  void _filterAppointments() {
    if (selectedDay == null) return;
    setState(() {
      filteredAppointments = allAppointments.where((a) {
        final date = a.startTime;
        return date.year == selectedDay!.year &&
            date.month == selectedDay!.month &&
            date.day == selectedDay!.day;
      }).toList();
    });
  }

  void _updateStatus(int id, String status) async {
    await DatabaseHelper().updateAppointmentStatus(id, status);
    await _loadAppointments();
  }

  void _updateMedicineStatus(int id, String status) async {
    await DatabaseHelper().updateMedicineStatus(id, status);
    await _loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        elevation: 0,
        title: const Text("Calendar", style: TextStyle(color: Colors.white)),
        actions: const [Icon(Icons.notifications, color: Colors.white), SizedBox(width: 16)],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D47A1), Color(0xFF42A5F5), Color(0xFF90CAF9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        selectedDay = selected;
                        focusedDay = focused;
                      });
                      _filterAppointments();
                      _loadMedicines();
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                    ),
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 127, 159),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Color.fromARGB(255, 73, 173, 255),
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: TextStyle(color: Colors.black54),
                      defaultTextStyle: TextStyle(color: Colors.black87),
                      outsideDaysVisible: false,
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.black54),
                      weekendStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    children: [
                      ...filteredAppointments.map((appt) => _buildAppointmentCard(appt)),
                      ..._medicines.map((med) => _buildMedicineCard(med)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF64B5F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_hospital, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(appt.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(appt.location, style: const TextStyle(color: Colors.white)),
          Text(
            DateFormat('EEE d MMM y, h:mm a').format(appt.startTime),
            style: const TextStyle(color: Colors.white70),
          ),
          const Divider(color: Colors.white54, thickness: 1, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => _updateStatus(appt.id!, 'skip'),
                child: Row(
                  children: const [
                    Icon(Icons.close, color: Colors.white),
                    SizedBox(width: 5),
                    Text("Skip", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _updateStatus(appt.id!, 'done'),
                child: Row(
                  children: const [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 5),
                    Text("Done", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          if (appt.status != 'pending')
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                appt.status == 'done' ? 'Done' : 'Skipped',
                style: TextStyle(
                  color: appt.status == 'done' ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildMedicineCard(MedicineModel med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF39CA5B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.pills, color: Colors.white),
              const SizedBox(width: 10),
              Text(med.name, style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            med.relation == 'before' ? "Before Meals" : "After Meals",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 6),
          ...med.timeStrings.entries.map((entry) => Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.white70),
                  SizedBox(width: 6),
                  Text("${entry.key[0].toUpperCase()}${entry.key.substring(1)} - ${entry.value}", style: TextStyle(color: Colors.white)),
                ],
              )),
          const Divider(color: Colors.white54, thickness: 1, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => _updateMedicineStatus(med.id!, 'skip'),
                child: Row(
                  children: const [
                    Icon(Icons.close, color: Colors.white),
                    SizedBox(width: 5),
                    Text("Skip", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _updateMedicineStatus(med.id!, 'done'),
                child: Row(
                  children: const [
                    Icon(Icons.check, color: Colors.white),
                    SizedBox(width: 5),
                    Text("Done", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          if (med.status != 'pending')
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                med.status == 'done' ? 'Done' : 'Skipped',
                style: TextStyle(
                  color: med.status == 'done' ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
        ],
      ),
    );
  }
}
