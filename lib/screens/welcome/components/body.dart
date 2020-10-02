import 'package:flutter/material.dart';
import 'package:sharelymeter/constants.dart';
import 'package:sharelymeter/screens/login/login_screen.dart';
import 'package:sharelymeter/screens/signup/signup_screen.dart';
import 'package:sharelymeter/screens/welcome/components/background.dart';
import 'package:sharelymeter/components/rounded_button.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center ,
        children: <Widget>[
          Text(
            "WELCOME TO SHARLY METER",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Image.asset(
            "assets/images/welcome.png",
            height : size.height * 0.5,
          ),
          SizedBox(height: size.height * 0.04),
          RoundedButton(
            text: "LOGIN",
            color: kPrimaryColor,
            textColor: Colors.white,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
                  },
                ),
              );
            },
          ),
          RoundedButton(
            text: "SIGN UP",
            color: kQuaternaryColor,
            textColor: kPrimaryColor,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}