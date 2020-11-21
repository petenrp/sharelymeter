import 'package:flutter/material.dart';
import 'package:sharelymeter/screens/home/components/body.dart';
import 'package:sharelymeter/shared/constants.dart'; 

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: null,
      body: Body(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      
    );
  }
}