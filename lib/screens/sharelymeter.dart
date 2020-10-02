import 'package:flutter/material.dart';
import 'package:sharelymeter/constants.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sharelymeter/screens/account/account_screen.dart';
import 'package:sharelymeter/screens/activity/activity_screen.dart';
import 'package:sharelymeter/screens/add/add_screen.dart';
import 'package:sharelymeter/screens/home/home_screen.dart';
import 'package:sharelymeter/screens/notification/notification_screen.dart';

class SharelyMeter extends StatefulWidget {
  @override
  _SharelyMeterState createState() => _SharelyMeterState();
}

class _SharelyMeterState extends State<SharelyMeter> {
  int _selectedItemIndex = 0;
  final List pages = [
    HomeScreen(),
    ActivityScreen(),
    AddScreen(),
    NotificationScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Row(
        children: <Widget>[
          buildNavBarItem(FlutterIcons.home_mdi, 0),
          buildNavBarItem(FlutterIcons.extension_mdi, 1),
          buildNavBarItem(FlutterIcons.add_circle_mdi, 2),
          buildNavBarItem(FlutterIcons.inbox_mdi, 3),
          buildNavBarItem(FlutterIcons.account_circle_mdi, 4),
        ],
      ),
      body: pages[_selectedItemIndex],
    );
  }

  Widget buildNavBarItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedItemIndex = index;
        });
      },
      child: Container(
        height: 80,
        padding: EdgeInsets.only(
          bottom: kDefaultPadding,
        ),
        width: MediaQuery.of(context).size.width / 5,
        decoration: BoxDecoration(
          //color: index == _selectedItemIndex ? kPrimaryColor: Colors.white,
          color: Colors.white,
        ),
        child: Icon(
          icon,
          size: 30,
          color: index == _selectedItemIndex ? kPrimaryColor : Colors.grey,
        ),
      ),
    );
  }
}
