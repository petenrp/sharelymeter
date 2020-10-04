import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharelymeter/models/userInformation.dart';

class DatabaseService{
  final String uid;
  DatabaseService({this.uid});

  //Collocetion reference
  final CollectionReference userInfoCollection = FirebaseFirestore.instance.collection('userInfo');

  Future updateUserData(String firstname, String lastname, String phonenumber, String email) async {
    return await userInfoCollection.doc(uid).set(
      {
        'firstname' : firstname,
        'lastname' : lastname,
        'phonenumber' : phonenumber,
        'email' : email,
      }
    );
  }
}