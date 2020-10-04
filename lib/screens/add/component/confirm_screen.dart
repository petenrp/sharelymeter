// import 'package:flutter/material.dart';
// import 'package:sharelymeter/prematching/map.dart';

// class ConfirmScreen extends StatefulWidget {
//   ConfirmScreen({Key key}) : super(key: key);

//   @override
//   _ConfirmScreenState createState() => _ConfirmScreenState();
// }

// class _ConfirmScreenState extends State<ConfirmScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: buildAppBar(),
//       // body: MapViewConfirmation(),
//     );
//   }

//   AppBar buildAppBar() {
//     return AppBar(
//       leading: SizedBox(),
//       centerTitle: true,
//       title: Text(
//         "Matching",
//       ),
//     );
//   }
// }

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sharelymeter/prematching/matching_page.dart';

class ConfirmScreen extends StatefulWidget {
  final double sLat;
  final double sLng;
  final double dLat;
  final double dLng;

  static const route = '/confirm-matching';

  ConfirmScreen({Key key, this.sLat, this.sLng, this.dLat, this.dLng})
      : super(key: key);

  @override
  _ConfirmScreenState createState() =>
      _ConfirmScreenState(sLat, sLng, dLat, dLng);
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  double sLat;
  double sLng;
  double dLat;
  double dLng;
  _ConfirmScreenState(this.sLat, this.sLng, this.dLat, this.dLng);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("data"),
      ),
      body: MapMatching(),
      // body: Container(
      //   height: 400,
      //   child: Column(
      //     children: [
      //       Text("Start Lat: " + sLat.toString()),
      //       Text("Start Lng: " + sLng.toString()),
      //       Text("Destination Lat: " + dLat.toString()),
      //       Text("Destination Lng: " + dLng.toString()),
      //     ],
      //   ),
      // ),
    );
  }
}
