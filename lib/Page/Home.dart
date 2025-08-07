import 'package:flutter/material.dart';
import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/Page/RegisterUser.dart';
import 'package:project_concert_closeiin/Page/User/HomeUser.dart';
import 'package:google_fonts/google_fonts.dart';

class homeLogoPage extends StatefulWidget {
  const homeLogoPage({super.key});

  @override
  State<homeLogoPage> createState() => _homeLogoPageState();
}

class _homeLogoPageState extends State<homeLogoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 230, 245),  
              Color.fromARGB(255, 242, 238, 243),  
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 100),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 130),
                            child: Text(
                              "Welcome",
                              style: GoogleFonts.poppins(
                                fontSize: 40,
                                color: const Color.fromARGB(255, 225, 90, 187),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                        Stack(
                          children: [
                            Positioned(
                              right: -10,
                              top: 40,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Image.asset(
                                  'assets/images/worldwide.png',
                                  width: 250,
                                  height: 250,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/images/LOGO.png',
                                width: 350,
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 190, 150, 198),
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPageUser(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.grey,
                                width: 2.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                color: const Color.fromARGB(255, 225, 90, 187),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeUser(),
                              ),
                            );
                          },
                          child: Text(
                            'Skip',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              color: const Color.fromARGB(255, 225, 90, 187),
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  Color.fromARGB(255, 225, 90, 187),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}