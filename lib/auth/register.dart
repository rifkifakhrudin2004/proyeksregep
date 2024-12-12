import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'package:animate_do/animate_do.dart';
import 'package:proyeksregep/auth/landing_page.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}
class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register(BuildContext context) async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Data Belum Lengkap",
        desc: "Silakan isi semua data sebelum melanjutkan.",
        btnOkOnPress: () {},
      ).show();
      return;
    }

    if (!emailController.text.contains('@')) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Email Tidak Valid",
        desc: "Silahkan masukkan email dengan domain yang benar.",
        btnOkOnPress: () {},
      ).show();
      return;
    }

    if (passwordController.text.length < 6) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Password Kurang Karakter",
        desc: "Password minimal harus memiliki 6 karakter.",
        btnOkOnPress: () {},
      ).show();
      return;
    }

    if (RegExp(r'^[0-9]+$').hasMatch(passwordController.text)) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Password Kurang Kuat",
        desc: "Password harus mengandung karakter selain angka.",
        btnOkOnPress: () {},
      ).show();
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Konfirmasi Password Salah",
        desc: "Password dan konfirmasi password tidak cocok.",
        btnOkOnPress: () {},
      ).show();
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: "Registrasi Berhasil",
        desc: "Akun Anda berhasil dibuat.",
        btnOkOnPress: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LandingPage()));
        },
      ).show();
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: "Registrasi Gagal",
        desc: "Gagal membuat akun: ${e.toString()}",
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
   final specificColor = const Color.fromRGBO(252, 228, 236, 1);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: specificColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: 
                      Text(
                        "Register",
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: const Color.fromRGBO(136, 14, 79, 1), 
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2
                          ),
                        ),
                      )),
                  SizedBox(height: 10),
                  FadeInUp(
                      duration: Duration(milliseconds: 1300),
                      child: Text(
                        "Create Your Account",
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: const Color.fromRGBO(136, 14, 79, 1), 
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 1.5,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60))),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 60),
                        FadeInUp(
                            duration: Duration(milliseconds: 1400),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: const Color.fromRGBO(255, 255, 255, 1),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: specificColor.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: Offset(0, 10))
                                  ]),
                              child: Column(
                                children: <Widget>[
                                  // Email TextField
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: const Color(0xFFEEEEEE)))),
                                    child: TextField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                          hintText: "Email",
                                          hintStyle:
                                              TextStyle(
                                                color: Color.fromRGBO(136, 14, 79, 1),
                                              ),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  // Password TextField
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade200))),
                                    child: TextField(
                                      controller: passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        hintText: "Password",
                                        hintStyle:
                                            TextStyle(color: Color.fromRGBO(136, 14, 79, 1)),
                                        border: InputBorder.none,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color.fromRGBO(136, 14, 79, 1),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Confirm Password TextField
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    child: TextField(
                                      controller: confirmPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      decoration: InputDecoration(
                                        hintText: "Confirm Password",
                                        hintStyle:
                                            TextStyle(color: Color.fromRGBO(136, 14, 79, 1)),
                                        border: InputBorder.none,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color.fromRGBO(136, 14, 79, 1),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(height: 40),
                        // Sign Up Button
                        FadeInUp(
                          duration: Duration(milliseconds: 1500),
                          child: GestureDetector(
                            onTap: () => _register(
                                context), // Make the entire area clickable
                            child: Container(
                              height: 50,
                              margin: EdgeInsets.symmetric(horizontal: 50),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: const Color.fromRGBO(136, 14, 79, 1)),
                              child: Center(
                                child: Text(
                                  "Sign Up",
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      letterSpacing: 1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        // Sign In Option
                        FadeInUp(
                          duration: Duration(milliseconds: 1600),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(color: const Color(0xFF9E9E9E)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          LandingPage(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;

                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        var offsetAnimation =
                                            animation.drive(tween);

                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign in",
                                  style: TextStyle(
                                      color: Color.fromRGBO(136, 14, 79, 1),
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
