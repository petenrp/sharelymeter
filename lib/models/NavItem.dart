import 'package:flutter/material.dart';
import 'package:sharelymeter/screens/account/account_screen.dart';
import 'package:sharelymeter/screens/activity/activity_screen.dart';
import 'package:sharelymeter/screens/add/add_screen.dart';
import 'package:sharelymeter/screens/home/home_screen.dart';
import 'package:sharelymeter/screens/notification/notification_screen.dart';

class NavItem {
  final int id;
  final String icon;
  final Widget destination;

  NavItem({this.id, this.icon, this.destination});

  bool destinationChecker() {
    if (destination != null) {
      return true;
    }
    return false;
  }
}

class NavItems extends ChangeNotifier {
  int selectedIndex = 0;

  void changeNavIndex({int index}) {
    selectedIndex = index;
    notifyListeners();
  }

  List<NavItem> items = [
    NavItem(
      id: 1,
      icon: "assets/icons/home-filled.svg",
      destination: HomeScreen(),
    ),
    NavItem(
      id: 2,
      icon: "assets/icons/activity-filled.svg",
      destination: ActivityScreen()
    ),
    NavItem(
      id: 3,
      icon: "assets/icons/add-filled.svg",
      destination: AddScreen()
    ),
    NavItem(
      id: 4,
      icon: "assets/icons/notification-filled.svg",
      destination: NotificationScreen()
    ),
    NavItem(
      id: 5,
      icon: "assets/icons/account-filled.svg",
      destination: AccountScreen()
    ),
  ];
}