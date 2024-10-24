import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> _register(BuildContext context) async {
  // Validasi email
  if (!emailController.text.contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Email harus mengandung '@' dan domain")),
    );
    return;
  }

  // Validasi password
  final password = passwordController.text;
  final passwordRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).+$'); // Regex untuk kombinasi huruf dan angka
  if (!passwordRegex.hasMatch(password)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Password harus kombinasi huruf dan angka")),
    );
    return;
  }

  // Validasi konfirmasi password
  if (password != confirmPasswordController.text) {
    print("Passwords do not match");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text,
      password: password,
    );
    // Berhasil register, arahkan ke halaman login
    Navigator.pushReplacementNamed(context, '/'); // Mengarahkan ke halaman login
  } catch (e) {
    print("Register failed: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registration failed: ${e.toString()}')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _register(context), // Kirim context ke fungsi _register
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
