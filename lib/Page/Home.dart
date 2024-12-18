import 'package:flutter/material.dart';
import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/Page/RegisterUser.dart';
import 'package:project_concert_closeiin/Page/User/HomeUser.dart';

class homeLogoPage extends StatefulWidget {
  const homeLogoPage({super.key});

  @override
  State<homeLogoPage> createState() => _homeLogoPageState();
}

class _homeLogoPageState extends State<homeLogoPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
         backgroundColor: const Color.fromARGB(255, 190, 150, 198),
         body: Column(
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
                        const Text(
                          "Concert Close Inn",
                           style: TextStyle(fontSize: 40,color:  Color.fromARGB(255, 225, 90, 187)),
                        ),
                        const SizedBox(height: 30),
                        // Image.asset(
                        //   'assets/images/deliveryLogo.png', 
                        //   width: 300, 
                        //   height: 300,
                        // ),
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
                            child: const Text(
                              'Login',
                              style: TextStyle(fontSize: 30,color: Colors.white),
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
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 30,color: Color.fromARGB(255, 225, 90, 187)),
                            ),
                          ),
                        ),
                         const SizedBox(height: 20),
                        GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeUser()), // Replace 'NextPage' with your target page
    );
  },
  child: Text(
    'Skip',
    style: TextStyle(
      fontSize: 24,
      color: Color.fromARGB(255, 225, 90, 187),
      decoration: TextDecoration.underline,
      decorationColor: Color.fromARGB(255, 225, 90, 187),
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