import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sharelymeter/components/rounded_button.dart';
import 'package:sharelymeter/screens/sharelymeter.dart';
import 'package:sharelymeter/service/auth.dart';
import 'info.dart';
import 'package:sharelymeter/database/database.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Retrieved{
  //Khemmy add
  String email = '';
  String firstname = '';
  String lastname = '';

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Widget build(BuildContext context) {
    final User user = auth.currentUser;
    final uid = user.uid;
    CollectionReference users = FirebaseFirestore.instance.collection('userInfo');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(user.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          print("sth went wrong");
          return Text("something went wrong");

        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
          print("Full Name: ${data['firstname']} ${data['lastname']}");
          return Text("Full Name: ${data['firstname']} ${data['lastname']}");
        }
        print("Loading");
        return Text("Loading");
      },
    );
  }
}

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
    FutureBuilder();
  }
}