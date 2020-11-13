import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class userInfoList extends StatefulWidget {
  userInfoList({Key key}) : super(key: key);

  @override
  _userInfoListState createState() => _userInfoListState();
}

class _userInfoListState extends State<userInfoList> {
  @override
  Widget build(BuildContext context) {

    final userInfo = Provider.of<QuerySnapshot>(context);
    print(userInfo);
    
    return Container(

    );
  }
}

class UserInfo{
  String email;
  String firstname;
  String lastname;
  String phonenumber;

  UserInfo.fromMap(Map<String, dynamic> data){
    email = data['email'];
    firstname = data['firstname'];
    lastname = data['lastname'];
    phonenumber = data['phonenumber'];
  }
}