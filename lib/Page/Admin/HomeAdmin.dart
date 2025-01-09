import 'package:flutter/material.dart';

class HomeAdmin extends StatefulWidget {
  int userId;
  HomeAdmin({super.key,  required this.userId});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(),
    );
  }
}