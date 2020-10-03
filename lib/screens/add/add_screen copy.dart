import 'package:flutter/material.dart';
import 'package:sharelymeter/googlemapapi.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sharelymeter/prematching/map.dart';

import 'dart:math' show cos, sqrt, asin;

class AddScreen extends StatefulWidget {
  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: buildAppBar(), body: MapView());
  }

  AppBar buildAppBar() {
    return AppBar(
      leading: SizedBox(),
      centerTitle: true,
      title: Text(
        "Find your sharely partner",
      ),
    );
  }
}
