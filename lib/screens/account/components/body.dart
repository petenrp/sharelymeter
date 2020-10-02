import 'package:flutter/material.dart';
import 'package:sharelymeter/components/rounded_button.dart';
import 'package:sharelymeter/service/auth.dart';
import 'info.dart';

class Body extends StatelessWidget {

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
