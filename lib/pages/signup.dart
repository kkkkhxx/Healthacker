import 'package:flutter/material.dart';
import '../models/user.dart';
import '../db/database.dart';
import '../pages/homepage.dart';
import 'package:sqflite/sqflite.dart'; 
import 'package:shared_preferences/shared_preferences.dart';



class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _signUp() async {
    String email = emailController.text.trim();

    // ตรวจสอบว่ามี email นี้ในระบบอยู่แล้วไหม
    UserModel? existingUser = await _dbHelper.getUserByEmail(email);
    if (existingUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email already exists")),
      );
      return;
    }

    // บันทึกข้อมูลใหม่
    UserModel newUser = UserModel(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: email,
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
    );

    await _dbHelper.insertUser(newUser);

// ✅ ดึง user ที่เพิ่งสมัครกลับมา (ใช้ email)
UserModel? signedUpUser = await _dbHelper.getUserByEmail(email);

// ✅ STEP 1: บันทึก userId
if (signedUpUser != null) {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('userId', signedUpUser.id!);
}

// ✅ แจ้งและไปหน้า HomePage หรือ Profile
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Account created successfully!")),
);

Navigator.pop(context); // กลับไปหน้า LoginPage ที่เคย push มาก่อน


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003765),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Text(
                'Create an account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              _buildInputField(firstNameController, 'Enter Your First Name'),
              SizedBox(height: 15),
              _buildInputField(lastNameController, 'Enter Your Last Name'),
              SizedBox(height: 15),
              _buildInputField(emailController, 'Enter Your Email'),
              SizedBox(height: 15),
              _buildInputField(phoneController, 'Enter Your Phone Number'),
              SizedBox(height: 15),
              _buildPasswordField(passwordController, 'Enter Your Password'),

              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE3D322),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFFFFF264),
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF01497C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: _obscurePassword,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: const Color(0xFF01497C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
