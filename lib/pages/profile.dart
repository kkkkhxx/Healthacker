import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottomnavbar.dart';
import '../layout/main_layout.dart';
import '../db/database.dart';
import '../models/user.dart';
import 'login.dart'; // เพิ่ม import หน้า Login

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isNotificationOn = true;
  bool isLocationOn = true;

  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      final db = DatabaseHelper();
      final user = await db.getUserById(userId);
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/ProfilePage.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Column(
            children: [
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Profile",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22)),
                    Icon(Icons.notifications, color: Colors.white),
                  ],
                ),
              ),

              SizedBox(height: 50),

              // Profile card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 16),
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: _user == null
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),

                            // Name
                            Text(
                              "${_user!.firstName} ${_user!.lastName}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 12),

                            // Phone
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone_outlined, size: 18),
                                SizedBox(width: 8),
                                Text(_user!.phone),
                              ],
                            ),
                            SizedBox(height: 8),

                            // Email
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.email_outlined, size: 18),
                                SizedBox(width: 8),
                                Text(_user!.email, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ],
                        ),
                ),
              ),

              SizedBox(height: 24),

              // Notification Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.notifications_none),
                        SizedBox(width: 12),
                        Text("Notification", style: TextStyle(fontSize: 16)),
                      ]),
                      Switch(
                        value: isNotificationOn,
                        onChanged: (value) {
                          setState(() {
                            isNotificationOn = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Location Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.location_on_outlined),
                        SizedBox(width: 12),
                        Text("Location", style: TextStyle(fontSize: 16)),
                      ]),
                      Switch(
                        value: isLocationOn,
                        onChanged: (value) {
                          setState(() {
                            isLocationOn = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // 🔴 Logout Button
              ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('userId'); // ลบ user session

                  // กลับไปหน้า LoginPage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text("Logout", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: Size(200, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
