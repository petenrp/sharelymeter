import 'package:flutter/material.dart';
import 'package:sharelymeter/shared/constants.dart';
import 'package:sharelymeter/screens/sharelymeter.dart';
import 'package:sharelymeter/screens/wrapper.dart';
import 'package:sharelymeter/service/auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sharelymeter/models/user.dart';

import './prematching/map.dart';
import './screens/add/component/confirm_screen.dart';

// import 'package:sharelymeter/prematching/map.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sharelymeter/googlemapapi.dart'; // Stores the Google Maps API Key
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:math' show cos, sqrt, asin;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error 1'),
          ),
        ),
      );
    }
    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('loading'),
          ),
        ),
      );
    }
    return StreamProvider<CustomUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sharely Meter',
        theme: ThemeData(
          scaffoldBackgroundColor: kBackgroundColor,
          primaryColor: kPrimaryColor,
          textTheme: Theme.of(context).textTheme.apply(bodyColor: kTextColor),
          appBarTheme: AppBarTheme(color: kPrimaryColor, elevation: 0),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Wrapper(),
        // home: SharelyMeter(),
        // home: ConfirmScreen(), //confirmation page
        routes: {
          //'/': (ctx) => SharelyMeter(),
          MapView.route: (ctx) => MapView(),
          // ConfirmScreen.route: (ctx) => ConfirmScreen(),
        },
      ),
    );
  }
}
