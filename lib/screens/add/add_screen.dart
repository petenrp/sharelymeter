import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharelymeter/models/user.dart';
import 'package:sharelymeter/prematching/map.dart';
import 'package:sharelymeter/shared/loading.dart';

class AddScreen extends StatefulWidget {
  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    CollectionReference users =
        FirebaseFirestore.instance.collection('userInfo');

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
          String name = data['firstname'] + " " + data['lastname'];
          String phoneNumber = data['phonenumber'];
          // print("Full Name: ${data['firstname']} ${data['lastname']}");
          // return Text("Full Name: ${data['firstname']} ${data['lastname']}");
          return Scaffold(
            appBar: buildAppBar(),
            body: MapView(
              userId: user.uid,
              fullName: name,
              phoneNumber: phoneNumber,
            ));
        }
        return Loading();
      },
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      leading: SizedBox(),
      centerTitle: true,
      title: Text(
        "Find your sharely partner",
      ),
    );
  }
}
