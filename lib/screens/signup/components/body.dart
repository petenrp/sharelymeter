import 'package:flutter/material.dart';
import 'package:sharelymeter/components/already_have_an_account_check.dart';
import 'package:sharelymeter/components/rounded_button.dart';
import 'package:sharelymeter/components/rounded_input_field.dart';
import 'package:sharelymeter/components/rounded_password_field.dart';
import 'package:sharelymeter/screens/login/login_screen.dart';
import 'package:sharelymeter/screens/signup/components/background.dart';
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
  //String confirmpassword = '';
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
                "SIGNUP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Image.asset(
                "assets/images/signup.png",
                height: size.height * 0.4,
              ),
              RoundedInputField(
                hintText: "Email",
                icon: Icons.email,
                validator: (value) => value.isEmpty ? 'Enter an Email': null,
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              RoundedPasswordField(
                validator: (value) => value.length < 6 ? 'Enter password 6 characters or more': null,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                hinttext: "Password",
              ),
              RoundedButton(
                text: "SIGNUP",
                press: () async {
                  if (_formkey.currentState.validate()) {
                    dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                    if(result == null) {
                      setState(() {
                        error = 'please provide a valid email';
                      }); 
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
                login: false,
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
            ],
          ),
        ),
      ),
    );
  }
}
