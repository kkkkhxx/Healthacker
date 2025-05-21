import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../pages/doctor.dart';
import '../pages/medicine.dart';
import '../pages/AddMonthlyPeroid.dart';
import '../layout/main_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectActivityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 2, // ปุ่มกลาง
      body: Scaffold(
        body: Stack(
          children: [
            // Background Gradient
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
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Activity',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          Icon(Icons.notifications, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 210),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Text(
                          'Select Your Activity',
                          style: TextStyle(fontSize: 22, color: Colors.black),
                        ),
                        SizedBox(height: 30),
                        _buildActivityButton(Icons.local_hospital_sharp, "Doctor's Appointment", context),
                        _buildActivityButton(FontAwesomeIcons.capsules, "Take Medicine", context),
                        _buildActivityButton(Icons.water_drop, "Monthly Period", context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 60,
              left: 40,
              right: 40,
              child: Image.asset(
                'assets/images/business-tasklist 1.png',
                height: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityButton(IconData icon, String label, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 57, 202, 91),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getInt('userId');
          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please log in first")),
            );
            return;
          }

          if (label == "Doctor's Appointment") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DoctorAppointmentPage()),
            );
          } else if (label == "Take Medicine") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TakeMedicinePage()),
            );
          } else if (label == "Monthly Period") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Addmonthlyperiod()),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 30),
            Icon(icon, size: 30, color: Colors.white),
            SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
