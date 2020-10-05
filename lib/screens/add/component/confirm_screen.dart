import 'package:flutter/material.dart';
import 'package:sharelymeter/prematching/matching_page.dart';

import '../../../database/firestore_db.dart';
import '../../../models/route.dart';

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
        title: Text("Confirm"),
      ),
      // body: Container(
      //     child: StreamBuilder<List<RouteModel>>(
      //       stream: routeDBS.streamList(),
      //       builder: (context, snapshot) {
      //         if (snapshot.hasData) {
      //           List<RouteModel> allRoutes = snapshot.data;
      //           if(allRoutes.isNotEmpty)
      //         };
      //       },
      //     ),
      //     ),
      body: MapMatching(),
    );
  }
}
