import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharelymeter/models/user.dart';
import 'package:sharelymeter/screens/sharelymeter.dart';
import 'package:sharelymeter/screens/welcome/welcomescreen.dart';

class Wrapper extends StatefulWidget {
  Wrapper({Key key}) : super(key: key);

  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<CustomUser>(context);
    print(user == null);

    if (user == null){
      return WelcomeScreen();
    } else {
      print("Sharely Meter");
      return SharelyMeter();
    }
  }
}