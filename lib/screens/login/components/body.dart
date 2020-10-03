import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sharelymeter/components/already_have_an_account_check.dart';
import 'package:sharelymeter/components/rounded_button.dart';
import 'package:sharelymeter/components/rounded_input_field.dart';
import 'package:sharelymeter/components/rounded_password_field.dart';
import 'package:sharelymeter/screens/login/components/background.dart';
import 'package:sharelymeter/screens/signup/signup_screen.dart';
import 'package:sharelymeter/service/auth.dart';

class Body extends StatefulWidget {
  Body({Key key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {

  final AuthService _auth = AuthService();
  final _formkey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "LOGIN",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Image.asset(
                "assets/images/login.png",
                height : size.height * 0.35,
              ),
              RoundedInputField(
                hintText: "Email",
                icon: Icons.email,
                validator: (value) => value.isEmpty ? 'Enter an Email': null,
                onChanged: (value){
                  email = value;
                },
              ),
              RoundedPasswordField(
                validator: (value) => value.length < 6 ? 'Enter password 6 characters or more': null,
                onChanged: (value){
                  setState(() {
                    password = value;
                  });
                },
                hinttext: "Password",
              ),
              RoundedButton(
                text: "LOGIN",
                press: () async {
                  if (_formkey.currentState.validate()) {
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                    if(result == null) {
                      setState(() {
                        error = 'could not login with thoes credentials';
                      }); 
                    } else {
                      Navigator.pop(context);
                    }
                  } 
                }
              ),
              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.0
                ),
              ),
              SizedBox(height: size.height * 0.02),
              AlreadyHaveAnAccountCheck(
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
        ),
      ),
    );
  } 
}

