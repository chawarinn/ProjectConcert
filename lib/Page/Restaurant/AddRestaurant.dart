import 'package:flutter/material.dart';

class AddRestaurant extends StatefulWidget {
  int userId;
  AddRestaurant({super.key,  required this.userId});

  @override
  State<AddRestaurant> createState() => _AddRestaurantState();
}

class _AddRestaurantState extends State<AddRestaurant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(),
    );
  }
}