import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import '../models/medicine_mod.dart';
import '../db/database.dart';

class ChatNotificationPage extends StatefulWidget {
  @override
  State<ChatNotificationPage> createState() => _ChatNotificationPageState();
}

class _ChatNotificationPageState extends State<ChatNotificationPage> {
  List<AppointmentModel> _todayAppointments = [];
  List<MedicineModel> _todayMedicines = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndData();
  }

  Future<void> _loadUserIdAndData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    if (userId != null) {
      await _loadTodayAppointments();
      await _loadTodayMedicines();
    }
  }

  Future<void> _loadTodayAppointments() async {
    final today = DateTime.now();
    final all = await DatabaseHelper().getAppointmentsByUser(userId!);
    setState(() {
      _todayAppointments = all.where((a) =>
          a.startTime.year == today.year &&
          a.startTime.month == today.month &&
          a.startTime.day == today.day).toList();
    });
  }

  Future<void> _loadTodayMedicines() async {
    final today = DateTime.now();
    final all = await DatabaseHelper().getAllMedicines(userId!);
    setState(() {
      _todayMedicines = all.where((m) =>
          m.date.year == today.year &&
          m.date.month == today.month &&
          m.date.day == today.day).toList();
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    await DatabaseHelper().updateAppointmentStatus(id, status);
    await _loadTodayAppointments();
  }

  Future<void> _updateMedicineStatus(int id, String status) async {
    await DatabaseHelper().updateMedicineStatus(id, status);
    await _loadTodayMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003765),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Chat", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: const [Icon(Icons.notifications, color: Colors.white), SizedBox(width: 16)],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(20),
        child: (_todayAppointments.isEmpty && _todayMedicines.isEmpty)
            ? _buildNoNotificationCard()
            : ListView(
                children: [
                  _buildWelcomeBubble("Hello"),
                  const SizedBox(height: 10),
                  ..._todayAppointments.map((appt) => _buildMessageBubble(
                        "You have an appointment: ${appt.title} at ${appt.location} today?",
                        messageTime: DateFormat('h:mm a').format(appt.startTime),
                        withButtons: appt.status == 'pending',
                        onDone: () => _updateStatus(appt.id!, 'done'),
                        onSkip: () => _updateStatus(appt.id!, 'skip'),
                        status: appt.status,
                      )),
                  ..._todayMedicines.map((med) => _buildMessageBubble(
                        "You have some medication to take ${med.relation == 'before' ? 'before' : 'after'} meals at ${_formatTimeMap(med.timeStrings)} today? Have you taken it yet?",
                        messageTime: DateFormat('h:mm a').format(DateTime.now()),
                        withButtons: med.status == 'pending',
                        onDone: () => _updateMedicineStatus(med.id!, 'done'),
                        onSkip: () => _updateMedicineStatus(med.id!, 'skip'),
                        status: med.status,
                      )),
                ],
              ),
      ),
    );
  }

  Widget _buildNoNotificationCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text("No notification 📭",
            style: TextStyle(fontSize: 16, color: Colors.black54)),
      ),
    );
  }

  Widget _buildWelcomeBubble(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFF0071CE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message, style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildMessageBubble(
    String message, {
    String? messageTime,
    bool withButtons = false,
    VoidCallback? onDone,
    VoidCallback? onSkip,
    String status = 'pending',
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0071CE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 10),
                const Divider(color: Colors.white30, thickness: 1),
                if (withButtons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: onSkip,
                        icon: Icon(Icons.close, color: Colors.white),
                        label: Text("Skip", style: TextStyle(color: Colors.white)),
                      ),
                      TextButton.icon(
                        onPressed: onDone,
                        icon: Icon(Icons.check, color: Colors.white),
                        label: Text("Done", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                else
                  Center(
                    child: Text(
                      status == 'done' ? '✅ Marked as Done' : '❌ Skipped',
                      style: TextStyle(
                        color: status == 'done' ? Colors.green : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            messageTime ?? DateFormat('hh:mm a').format(DateTime.now()),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  String _formatTimeMap(Map<String, String> timeMap) {
    return timeMap.entries.map((e) => "${_capitalize(e.key)} ${e.value}").join(" | ");
  }
}
