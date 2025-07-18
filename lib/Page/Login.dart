import 'dart:core';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:project_concert_closeiin/Page/Admin/HomeAdmin.dart';
import 'package:project_concert_closeiin/Page/Event/AddEvent.dart';
import 'package:project_concert_closeiin/Page/Hotel/HomeHotel.dart';
import 'package:project_concert_closeiin/Page/Member/HomeMember.dart';
import 'package:project_concert_closeiin/Page/Member/hotel_search.dart';
import 'package:project_concert_closeiin/Page/Restaurant/AddRestaurant.dart';
import 'package:project_concert_closeiin/config/config.dart';
import 'package:project_concert_closeiin/config/internet_config.dart';
import 'package:project_concert_closeiin/model/request/userPostLoginRequest.dart';
import 'package:project_concert_closeiin/model/response/userPostLoginResponse.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var emailCtl = TextEditingController();
  var passwordCtl = TextEditingController();
  String text = '';
  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then(
      (config) {
        url = config['apiEndpoint'];
      },
    ).catchError((err) {
      log(err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(201, 151, 187, 1),
        title: Text(
          'Login',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(10, 40, 10, 10),
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage('assets/images/Profile.png'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Login",
                  style: GoogleFonts.poppins(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    TextField(
                      controller: emailCtl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromRGBO(217, 217, 217, 1),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    TextField(
                      controller: passwordCtl,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromRGBO(217, 217, 217, 1),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 0, 91, 228),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color.fromARGB(255, 0, 91, 228),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (emailCtl.text.isEmpty || passwordCtl.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Notification',
                              ),
                              content: Text(
                                'กรุณากรอก Email และ Password ให้ครบถ้วน',
                                style: GoogleFonts.poppins(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'OK',
                                     style: TextStyle(color: Colors.black)
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      if (emailCtl.text.contains(' ') ||
                          emailCtl.text.trim() != emailCtl.text) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Notification',
                              ),
                              content: Text(
                                'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
                                style: GoogleFonts.poppins(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'OK',
                                     style: TextStyle(color: Colors.black)
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      } else {
                        loginU();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 190, 150, 198),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
//   void showLoadingDialog() {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => Center(
//       child: CircularProgressIndicator(),
//     ),
//   );
// }

// void hideLoadingDialog() {
//   Navigator.of(context, rootNavigator: true).pop();
// }

  void loginU() async {
    // showLoadingDialog();
    log(emailCtl.text);
    log(passwordCtl.text);
    try {
      var data = UsersLoginPostRequest(
          email: emailCtl.text.trim(), password: passwordCtl.text);

      var value = await http.post(Uri.parse('$API_ENDPOINT/login'),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: usersLoginPostRequestToJson(data));

      UsersLoginPostResponse users = usersLoginPostResponseFromJson(value.body);
      log(value.body);
      log(users.user.userId.toString());
      setState(() {
        text = '';
      });

      switch (users.user.typeId) {
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Homemember(userId: users.user.userId),
            ),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeHotel(userId: users.user.userId),
            ),
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRestaurant(userId: users.user.userId),
            ),
          );
          break;
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEvent(userId: users.user.userId),
            ),
          );
          break;
        case 5:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeAdmin(userId: users.user.userId),
            ),
          );
          break;
      }
    } catch (error) {
      // hideLoadingDialog();
      log(error.toString() );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                                'Notification',
                              ),
            content: Text(
              'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                   style: TextStyle(color: Colors.black)
                ),
              ),
            ],
          );
        },
      );

      setState(() {
        text = 'email no or password incorrect';
      });
    }
  }
}
