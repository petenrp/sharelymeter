import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //firebase
import 'dart:async';
import 'dart:io';

class MatchinngPage extends StatefulWidget {
  MatchinngPage({Key key}) : super(key: key);

  @override
  _MatchinngPageState createState() => _MatchinngPageState();
}

class _MatchinngPageState extends State<MatchinngPage> {
  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     child: Column(
  //       children: [new Text("From $_startAddress to $_destinationAddress")],
  //     ),
  //   );
  // }
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;

  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> snapshot;

  @override
  void initState() {
    super.initState();
    readDatabase(context);
    readFireStore();
  }

  Future readFireStore() async {
    CollectionReference collectionReference =
        firestore.collection('MatchingRoute');
    subscription = await collectionReference.snapshots().listen((dataSnapshot) {
      snapshots = dataSnapshot.documents;

      for (var snapshot in snapshots) {
        double startLat = snapshot.data['startLat'];
        double startLng = snapshot.data['startLat'];
        double destLat = snapshot.data['startLat'];
        double destLng = snapshot.data['startLat'];

        print('startLat ==> $startLat');
      }
    });
  }
}
