
import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/homepage.dart';
import 'pages/signup.dart';
import 'pages/calendar.dart';
import 'pages/notification.dart';
import 'pages/selectactivity.dart';
import 'pages/profile.dart';
import 'layout/main_layout.dart';
import 'widgets/homecontent.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Poppins'),
      title: 'Login UI',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // ใช้ '/' ให้ตรงกับ route ที่กำหนดด้านล่าง
      routes: {
        '/': (context) => LoginPage(), 
        '/signup': (context) => SignUpPage(),
         '/homepage': (context) => MainLayout(selectedIndex: 0, body: HomeContent()),
        '/calendar': (context) => MainLayout(selectedIndex: 1, body: CalendarPage()),
        '/chat': (context) => MainLayout(selectedIndex: 3, body: ChatNotificationPage()),
        '/profile': (context) => MainLayout(selectedIndex: 4, body: ProfilePage()),
        '/selectactivity': (context) => SelectActivityPage(),
      },
    );
  }
}
