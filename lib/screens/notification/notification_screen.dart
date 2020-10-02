import 'package:flutter/material.dart';
import 'package:sharelymeter/screens/notification/components/body.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Body(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      leading: SizedBox(),
      centerTitle: true,
      title: Text(
        "Notification",
      ),
    );
  }
}