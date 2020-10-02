import 'package:flutter/material.dart';
import 'package:sharelymeter/constants.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: buildAppBar(),
        body: TabBarView(
          children: [
            Icon(Icons.apps),
            Icon(Icons.movie),
            Icon(Icons.games),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: SizedBox(),
      centerTitle: true,
      title: Text(
        "Activity",
        style : TextStyle(
          color: kPrimaryColor,
          fontWeight: FontWeight.bold
        ),
      ),
      bottom: TabBar(
        unselectedLabelColor: kSecondaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), 
            topRight:Radius.circular(10),
          ),
          color: kSecondaryColor,
        ),
        tabs: [ 
          Tab(
            child: Align(
              alignment: Alignment.center,
              child: Text("Schedule"),
            ),
          ),
          Tab(
            child: Align(
              alignment: Alignment.center,
              child: Text("Processing"),
            ),
          ),
          Tab(
            child: Align(
              alignment: Alignment.center,
              child: Text("History"),
            ),
          ),
        ],
      ),
    );
  }
}