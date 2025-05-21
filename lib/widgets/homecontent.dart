import 'package:flutter/material.dart';
import 'package:healthacker2/pages/AddMonthlyPeroid.dart';
import 'package:healthacker2/pages/doctor.dart';
import 'package:healthacker2/pages/medicine.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import '../models/period.dart';
import '../db/database.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  AppointmentModel? nextAppointment;
  DateTime? _lastPeriodDate;

  double progress = 1.0;
  int doneCount = 0;
  int totalCount = 0;

  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    final dateStr = prefs.getString('last_period_date');

    if (id == null) return;

    setState(() {
      userId = id;
      if (dateStr != null) {
        _lastPeriodDate = DateTime.parse(dateStr);
      }
    });

    await _loadNextAppointment();
    await _loadTodayMedicineProgress();
  }

  Future<void> _loadNextAppointment() async {
    if (userId == null) return;
    final all = await DatabaseHelper().getAppointmentsByUser(userId!);
    final now = DateTime.now();
    final upcoming = all.where((a) => a.startTime.isAfter(now)).toList();
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
    setState(() {
      nextAppointment = upcoming.isNotEmpty ? upcoming.first : null;
    });
  }

  Future<void> _loadTodayMedicineProgress() async {
    if (userId == null) return;
    final today = DateTime.now();
    final meds = await DatabaseHelper().getAllMedicines(userId!);
    final todayMeds = meds
        .where((m) =>
            m.date.year == today.year &&
            m.date.month == today.month &&
            m.date.day == today.day)
        .toList();

    totalCount = todayMeds.length;
    doneCount = todayMeds.where((m) => m.status == 'done').length;

    setState(() {
      progress = (totalCount == 0) ? 1.0 : doneCount / totalCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {
      "Completed": (progress * 100).roundToDouble(),
      "Remaining": 100 - (progress * 100).roundToDouble(),
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Home', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 300,
            child: Image.asset(
              'assets/images/HomePageTopNav.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 300),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_lastPeriodDate != null) _buildPeriodCard(),
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressCard(dataMap),
                        SizedBox(width: 30),
                        Expanded(child: _buildAppointmentCard()),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildIconButton(
                          icon: Icons.local_hospital_sharp,
                          color: Color.fromARGB(255, 98, 52, 222),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorAppointmentPage(),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        _buildIconButton(
                          icon: FontAwesomeIcons.capsules,
                          color: const Color.fromARGB(255, 57, 202, 91),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TakeMedicinePage(),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        _buildIconButton(
                          icon: Icons.water_drop,
                          color: Color.fromARGB(255, 255, 127, 159),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Addmonthlyperiod(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(child: Icon(icon, color: Colors.white, size: 28)),
      ),
    );
  }

  Widget _buildPeriodCard() {
    final next = _lastPeriodDate!.add(Duration(days: 28));
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF64B5F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.water_drop, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Monthly Period",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Next Period : ${DateFormat('d MMM yyyy').format(next)}",
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 2),
                Text(
                  "${_daysUntilNextPeriod()} days until next period",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd').format(next),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(next),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Map<String, double> dataMap) {
    return Container(
      width: 130,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Today",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                dataMap: dataMap,
                chartType: ChartType.ring,
                ringStrokeWidth: 16,
                colorList: [Colors.white, Colors.white.withOpacity(0.3)],
                legendOptions: LegendOptions(showLegends: false),
                chartValuesOptions: ChartValuesOptions(showChartValues: false),
              ),
              Column(
                children: [
                  Icon(
                    FontAwesomeIcons.capsules,
                    color: Colors.white,
                    size: 24,
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF585AE2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_box_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Next Appointment",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (nextAppointment != null) ...[
            Text(
              nextAppointment!.title,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            SizedBox(height: 2),
            Text(
              nextAppointment!.location,
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 2),
            Text(
              DateFormat('EEE d MMM yyyy, h:mm a')
                  .format(nextAppointment!.startTime),
              style: TextStyle(color: Colors.white70),
            ),
          ] else
            Text(
              "No upcoming appointments",
              style: TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }

  int _daysUntilNextPeriod() {
    final next = _lastPeriodDate!.add(Duration(days: 28));
    return next.difference(DateTime.now()).inDays;
  }
}
