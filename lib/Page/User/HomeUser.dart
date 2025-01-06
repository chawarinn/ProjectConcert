import 'package:flutter/material.dart';
import 'package:project_concert_closeiin/Page/Login.dart';
import 'package:project_concert_closeiin/Page/RegisterUser.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 190, 150, 198),
          automaticallyImplyLeading: false,
          title: const Text(
            'Concert Close Inn',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onSelected: (value) {
                if (value == 'Login') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const LoginPage()), // Navigate to Login page
                  );
                } else if (value == 'Sign Up') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const RegisterPageUser()), // Navigate to Sign Up page
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'Login',
                  child: Text('Login'),
                ),
                const PopupMenuItem<String>(
                  value: 'Sign Up',
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, // ใช้ความกว้างของหน้าจอทั้งหมด
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Color.fromARGB(255, 217, 217, 217),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                      child:Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Expanded(
      // ทำให้ TextField ขยายเต็มที่
      child: TextField(
        onChanged: (value) {
          // การจัดการค่าที่พิมพ์ในช่อง search
        },
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Colors.grey, // เปลี่ยนสีของ hintText
            fontSize: 16, // ปรับขนาดตัวอักษร
          ),
          filled: true, // เปิดใช้งานการเติมสีพื้นหลัง
          fillColor: Colors.white, // กำหนดสีพื้นหลังให้เป็นสีขาว
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 1, color: Colors.white),
          ),
        ),
      ),
    ),
    const SizedBox(width: 10), // เว้นช่องระหว่าง TextField และ Icon
    Icon(Icons.search), // ไอคอนที่อยู่ข้างๆ ช่องค้นหา
  ],
)

                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
