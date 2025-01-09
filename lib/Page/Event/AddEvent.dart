import 'package:flutter/material.dart';

class AddEvent extends StatefulWidget {
  int userId;
  AddEvent({super.key,  required this.userId});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(),
    );
  }
}