import 'package:flutter/material.dart';
import 'package:sharelymeter/screens/account/components/body.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Body(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      // backgroundColor: kPrimaryColor,
      leading: SizedBox(),
      centerTitle: true,
      title: Text("Account"),
      actions: <Widget>[
          FlatButton(
            onPressed: () {},
            child: Text(
              "Edit",
              style: TextStyle(
                color: Colors.white,                    
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      );
  }
}