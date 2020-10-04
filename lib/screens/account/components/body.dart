import 'package:flutter/material.dart';
import 'package:sharelymeter/components/rounded_button.dart';
import 'package:sharelymeter/service/auth.dart';
import 'info.dart';
import 'package:sharelymeter/database/database.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
        children: <Widget>[
          Info(
            image: "assets/images/pic.png",
            name: "Jaehyun Jeong",
            email: "_jeongjaehyun@gmail.com",
          ),
          RoundedButton(
            text: "LOG OUT",
                press: () async {
                  await _auth.signOut();
                },
          )
        ],
      ),
    );
  }
}