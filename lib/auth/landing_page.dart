import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyeksregep/pages/home_page.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: "Error",
        desc: "Silahkan masukkan email dan password terlebih dahulu.",
        btnOkOnPress: () {},
      ).show();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutQuart,
              )),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.leftSlide,
        title: "Login Gagal",
        desc: "Email atau password yang Anda masukkan salah.",
        btnOkOnPress: () {},
        btnOkColor: Colors.red,
      ).show();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(248, 187, 208, 1),
              Color.fromRGBO(255, 205, 210, 1),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height / 2.2,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(252, 228, 236, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(65),
                    topRight: Radius.circular(65),
                  ),
                ),
                child: FadeInDown(
                  duration: Duration(milliseconds: 800),
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/login.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height / 1.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 30,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInLeft(
                        child: Text(
                          "Welcome Back",
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: const Color.fromRGBO(136, 14, 79, 1),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      FadeInLeft(
                        delay: Duration(milliseconds: 200),
                        child: Text(
                          "Sign in to continue",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      FadeInUp(
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email/Username",
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: const Color.fromRGBO(136, 14, 79, 1),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      FadeInUp(
                        delay: Duration(milliseconds: 200),
                        child: TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: const Color.fromRGBO(136, 14, 79, 1),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color.fromRGBO(136, 14, 79, 1),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      FadeInUp(
                        delay: Duration(milliseconds: 400),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(136, 14, 79, 1),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : () => _login(context),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                : Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      FadeInUp(
                        delay: Duration(milliseconds: 600),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  color: const Color.fromRGBO(136, 14, 79, 1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
