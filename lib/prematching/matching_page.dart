import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// Stores the Google Maps API Key
import 'package:sharelymeter/googlemapapi.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //firebase
import 'dart:async';
import '../models/route.dart';
import '../database/firestore_db.dart';
import 'package:firebase_helpers/firebase_helpers.dart';
import 'package:sharelymeter/shared/constants.dart';

import '../screens/add/component/confirm_screen.dart';

import 'dart:math' show cos, sqrt, asin;

//khem
import 'package:sharelymeter/database/dbformatching.dart';
import 'package:firebase_auth/firebase_auth.dart';

//SocketIO
import 'package:socket_io/socket_io.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MapMatching extends StatefulWidget {
  static const route = '/pre-matching';
  final double sLat;
  final double sLng;
  final double dLat;
  final double dLng;

  MapMatching({this.sLat, this.sLng, this.dLat, this.dLng});

  @override
  _MapMatchingState createState() => _MapMatchingState();
}

class _MapMatchingState extends State<MapMatching> {
  //test
  final RouteModel route;
  _MapMatchingState({this.route, this.sLat, this.sLng, this.dLat, this.dLng});

  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;

  final Geolocator _geolocator = Geolocator();

  Position _currentPosition;
  String _currentAddress;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance = '';

  double sLat = 0;
  double sLng = 0;
  double dLat = 0;
  double dLng = 0;

  double startLat = 13.6512206;
  double startLng = 100.4941857;
  double destLat = 13.6048378;
  double destLng = 100.3725301;
  double totalDistance = 0;

  Set<Marker> markers = {};

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //SocketIO
  IO.Socket socket = IO.io('https://afternoon-tor-56476.herokuapp.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
  });
  


  Widget _textField({
    TextEditingController controller,
    String label,
    String hint,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue[300],
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POSITION: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await _geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      //currennt location name
      // setState(() {
      //   _currentAddress =
      //       "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
      //   startAddressController.text = _currentAddress;
      //   _startAddress = _currentAddress;
      // });

    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Placemark> startPlacemark =
          await _geolocator.placemarkFromAddress(_startAddress);
      List<Placemark> destinationPlacemark =
          await _geolocator.placemarkFromAddress(_destinationAddress);

      if (startPlacemark != null && destinationPlacemark != null) {
        // Use the retrieved coordinates of the current position,
        // instead of the address if the start position is user's
        // current position, as it results in better accuracy.
        Position startCoordinates = _startAddress == _currentAddress
            ? Position(
                latitude: _currentPosition.latitude,
                longitude: _currentPosition.longitude)
            : startPlacemark[0].position;
        Position destinationCoordinates = destinationPlacemark[0].position;

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(
            destinationCoordinates.latitude,
            destinationCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        startLat = startCoordinates.latitude;
        startLng = startCoordinates.longitude;
        destLat = destinationCoordinates.latitude;
        destLng = destinationCoordinates.longitude;

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);

        // print('START COORDINATES: $startCoordinates');
        print('START COORDINATES: $startLat, $startLng');
        // print('DESTINATION COORDINATES: $destinationCoordinates');
        print('DESTINATION COORDINATES: $destLat, $destLng');

        Position _northeastCoordinates;
        Position _southwestCoordinates;

        // Calculating to check that
        // southwest coordinate <= northeast coordinate
        if (startCoordinates.latitude <= destinationCoordinates.latitude) {
          _southwestCoordinates = startCoordinates;
          _northeastCoordinates = destinationCoordinates;
        } else {
          _southwestCoordinates = destinationCoordinates;
          _northeastCoordinates = startCoordinates;
        }

        // Accommodate the two locations within the
        // camera view of the map
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
              ),
            ),
            100.0,
          ),
        );

        await _createPolylines(startCoordinates, destinationCoordinates);

        setState(() {
          _placeDistance = totalDistance.toStringAsFixed(2);
          print('DISTANCE: $_placeDistance km');
        });

        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Create the polylines for showing the route between two places
  _createPolylines(Position start, Position destination) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GmapAPI.API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    print('Connecting');
    this.socket.on('connect', (_) {
      print('Connected');
    });
    this.socket.connect();
  }

  @override
  void dispose() {
    super.dispose();
    this.socket.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          // Map View
          GoogleMap(
            markers: markers != null ? Set<Marker>.from(markers) : null,
            initialCameraPosition: _initialLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          // Showing Result
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  width: width * 0.9,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        SizedBox(height: 5),
                        _textField(
                            label: 'From',
                            width: width,
                            locationCallback: (String value) {}),
                        SizedBox(height: 5),
                        _textField(
                            label: 'To',
                            width: width,
                            locationCallback: (String value) {}),
                        SizedBox(height: 5),
                        SizedBox(height: 0),
                        // RaisedButton(
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

