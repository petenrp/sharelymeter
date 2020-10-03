import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{
  final String uid;
  DatabaseService({this.uid});

  //Collocetion reference
  final CollectionReference userInfoCollection = FirebaseFirestore.instance.collection('userInfo');

  Future updateUserData(String firstname, String lastname, String phonenumber) async {
    return await userInfoCollection.doc(uid).set(
      {
        'firstname' : firstname,
        'lastname' : lastname,
        'phonenumber' : phonenumber,
      }
    );
  }
}