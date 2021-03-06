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

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Maps',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MapView(),
//     );
//   }
// }

class MapView extends StatefulWidget {
  static const route = '/pre-matching';
  final double sLat;
  final double sLng;
  final double dLat;
  final double dLng;

  MapView({this.sLat, this.sLng, this.dLat, this.dLng});

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  //test
  final RouteModel route;
  _MapViewState({this.route, this.sLat, this.sLng, this.dLat, this.dLng});

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

  double startLat = 0;
  double startLng = 0;
  double destLat = 0;
  double destLng = 0;
  double totalDistance = 0;

  Set<Marker> markers = {};

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
        print('CURRENT POS: $_currentPosition');
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

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
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

        // Calculating the distance between the start and the end positions
        // with a straight path, without considering any route
        // double distanceInMeters = await Geolocator().bearingBetween(
        //   startCoordinates.latitude,
        //   startCoordinates.longitude,
        //   destinationCoordinates.latitude,
        //   destinationCoordinates.longitude,
        // );

        await _createPolylines(startCoordinates, destinationCoordinates);

        totalDistance = 0.0;

        // Calculating the total distance by adding the distance
        // between small segments
        for (int i = 0; i < polylineCoordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude,
          );
        }

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

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
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
          // showing the route
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
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
                          'Places',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        SizedBox(height: 5),
                        _textField(
                            label: 'Start',
                            hint: 'Choose starting point',
                            prefixIcon: Icon(Icons.looks_one),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.my_location),
                              onPressed: () {
                                startAddressController.text = _currentAddress;
                                _startAddress = _currentAddress;
                              },
                            ),
                            controller: startAddressController,
                            width: width,
                            locationCallback: (String value) {
                              setState(() {
                                _startAddress = value;
                                print(_startAddress);
                              });
                            }),
                        // Stop point
                        // SizedBox(height: 5),
                        // _textField(
                        //     label: 'Stop',
                        //     hint: 'Pin stop point',
                        //     prefixIcon: Icon(Icons.looks_one),
                        //     suffixIcon: IconButton(
                        //       icon: Icon(Icons.my_location),
                        //       onPressed: () {
                        //         startAddressController.text = _currentAddress;
                        //         _startAddress = _currentAddress;
                        //       },
                        //     ),
                        //     controller: startAddressController,
                        //     width: width,
                        //     locationCallback: (String value) {
                        //       setState(() {
                        //         _startAddress = value;
                        //         print(_startAddress);
                        //       });
                        //     }),
                        SizedBox(height: 5),
                        _textField(
                            label: 'Destination',
                            hint: 'Choose destination',
                            prefixIcon: Icon(Icons.looks_two),
                            controller: destinationAddressController,
                            width: width,
                            locationCallback: (String value) {
                              setState(() {
                                _destinationAddress = value;
                                print(_destinationAddress);
                              });
                            }),
                        SizedBox(height: 5),
                        Visibility(
                          visible: _placeDistance == null ? false : true,
                          child: Text(
                            'DISTANCE: $_placeDistance km',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 0),
                        RaisedButton(
                          onPressed: (_startAddress != '' &&
                                  _destinationAddress != '')
                              ? () async {
                                  setState(() {
                                    if (markers.isNotEmpty) markers.clear();
                                    if (polylines.isNotEmpty) polylines.clear();
                                    if (polylineCoordinates.isNotEmpty)
                                      polylineCoordinates.clear();
                                    _placeDistance = null;
                                  });

                                  _calculateDistance().then((isCalculated) {
                                    if (isCalculated) {
                                      _scaffoldKey.currentState.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Distance Calculated Sucessfully'),
                                        ),
                                      );
                                    } else {
                                      _scaffoldKey.currentState.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Error Calculating Distance'),
                                        ),
                                      );
                                    }
                                  });
                                }
                              : null,
                          color: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Show Route'.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0, bottom: 25.0),
                child: ClipOval(
                  child: Material(
                    color: Colors.orange[100], // button color
                    child: InkWell(
                      splashColor: Colors.orange, // inkwell color
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(Icons.my_location),
                      ),
                      onTap: () {
                        mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                _currentPosition.latitude,
                                _currentPosition.longitude,
                              ),
                              zoom: 18.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              child: new AlertDialog(
                title: Text("Confirmation"),
                content: Container(
                  //color: Colors.amber,
                  height: 120,
                  child: Column(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Start: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                ),
                                Text(
                                  _startAddress,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Destination: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                ),
                                Text(
                                  _destinationAddress,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FlatButton(
                        onPressed: () async {
                          sLat = startLat;
                          sLng = startLng;
                          dLat = destLat;
                          dLng = destLng;
                          // Navigator.of(context).push(route)

                          await routeDBS.createItem(
                            RouteModel(
                              userID: '',
                              startLat: startLat,
                              startLng: startLng,
                              destLat: destLat,
                              destLng: destLng,
                              totalDistance: totalDistance,
                              startAddress: _startAddress,
                              destinationAdress: _destinationAddress,
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmScreen(
                                sLat: sLat,
                                sLng: sLng,
                                dLat: dLat,
                                dLng: dLng,
                              ),
                            ),
                          );
                        },
                        child: Text("Yes"),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("No"),
                      ),
                    ],
                  ),
                ],
                // Column(
                //   children: [
                //     Text("data"),
                //   ],
                // ),
              ),
            );
          },
          child: Icon(Icons.done_all),
          backgroundColor: Colors.red),
    );

    // Container(
    //   height: height,
    //   width: width,
    //   child: Scaffold(
    //     key: _scaffoldKey,
    //     body: Stack(
    //       children: <Widget>[
    //         // Map View
    //         GoogleMap(
    //           markers: markers != null ? Set<Marker>.from(markers) : null,
    //           initialCameraPosition: _initialLocation,
    //           myLocationEnabled: true,
    //           myLocationButtonEnabled: false,
    //           mapType: MapType.normal,
    //           zoomGesturesEnabled: true,
    //           zoomControlsEnabled: false,
    //           polylines: Set<Polyline>.of(polylines.values),
    //           onMapCreated: (GoogleMapController controller) {
    //             mapController = controller;
    //           },
    //         ),
    //         // Show zoom buttons
    //         // SafeArea(
    //         //   child: Padding(
    //         //     padding: const EdgeInsets.only(left: 10.0),
    //         //     child: Column(
    //         //       mainAxisAlignment: MainAxisAlignment.center,
    //         //       children: <Widget>[
    //         //         ClipOval(
    //         //           child: Material(
    //         //             color: Colors.blue[100], // button color
    //         //             child: InkWell(
    //         //               splashColor: Colors.blue, // inkwell color
    //         //               child: SizedBox(
    //         //                 width: 50,
    //         //                 height: 50,
    //         //                 child: Icon(Icons.add),
    //         //               ),
    //         //               onTap: () {
    //         //                 mapController.animateCamera(
    //         //                   CameraUpdate.zoomIn(),
    //         //                 );
    //         //               },
    //         //             ),
    //         //           ),
    //         //         ),
    //         //         SizedBox(height: 20),
    //         //         ClipOval(
    //         //           child: Material(
    //         //             color: Colors.blue[100], // button color
    //         //             child: InkWell(
    //         //               splashColor: Colors.blue, // inkwell color
    //         //               child: SizedBox(
    //         //                 width: 50,
    //         //                 height: 50,
    //         //                 child: Icon(Icons.remove),
    //         //               ),
    //         //               onTap: () {
    //         //                 mapController.animateCamera(
    //         //                   CameraUpdate.zoomOut(),
    //         //                 );
    //         //               },
    //         //             ),
    //         //           ),
    //         //         )
    //         //       ],
    //         //     ),
    //         //   ),
    //         // ),
    //         // Show the place input fields & button for
    //         // showing the route
    //         SafeArea(
    //           child: Align(
    //             alignment: Alignment.topCenter,
    //             child: Padding(
    //               padding: const EdgeInsets.only(top: 5.0),
    //               child: Container(
    //                 decoration: BoxDecoration(
    //                   color: Colors.white70,
    //                   borderRadius: BorderRadius.all(
    //                     Radius.circular(20.0),
    //                   ),
    //                 ),
    //                 width: width * 0.9,
    //                 child: Padding(
    //                   padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
    //                   child: Column(
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: <Widget>[
    //                       Text(
    //                         'Places',
    //                         style: TextStyle(fontSize: 20.0),
    //                       ),
    //                       SizedBox(height: 5),
    //                       _textField(
    //                           label: 'Start',
    //                           hint: 'Choose starting point',
    //                           prefixIcon: Icon(Icons.looks_one),
    //                           suffixIcon: IconButton(
    //                             icon: Icon(Icons.my_location),
    //                             onPressed: () {
    //                               startAddressController.text = _currentAddress;
    //                               _startAddress = _currentAddress;
    //                             },
    //                           ),
    //                           controller: startAddressController,
    //                           width: width,
    //                           locationCallback: (String value) {
    //                             setState(() {
    //                               _startAddress = value;
    //                               print(_startAddress);
    //                             });
    //                           }),
    //                       SizedBox(height: 5),
    //                       _textField(
    //                           label: 'Destination',
    //                           hint: 'Choose destination',
    //                           prefixIcon: Icon(Icons.looks_two),
    //                           controller: destinationAddressController,
    //                           width: width,
    //                           locationCallback: (String value) {
    //                             setState(() {
    //                               _destinationAddress = value;
    //                               print(_destinationAddress);
    //                             });
    //                           }),
    //                       SizedBox(height: 5),
    //                       Visibility(
    //                         visible: _placeDistance == null ? false : true,
    //                         child: Text(
    //                           'DISTANCE: $_placeDistance km',
    //                           style: TextStyle(
    //                             fontSize: 15,
    //                             fontWeight: FontWeight.bold,
    //                           ),
    //                         ),
    //                       ),
    //                       SizedBox(height: 0),
    //                       RaisedButton(
    //                         onPressed: (_startAddress != '' &&
    //                                 _destinationAddress != '')
    //                             ? () async {
    //                                 setState(() {
    //                                   if (markers.isNotEmpty) markers.clear();
    //                                   if (polylines.isNotEmpty)
    //                                     polylines.clear();
    //                                   if (polylineCoordinates.isNotEmpty)
    //                                     polylineCoordinates.clear();
    //                                   _placeDistance = null;
    //                                 });

    //                                 _calculateDistance().then((isCalculated) {
    //                                   if (isCalculated) {
    //                                     _scaffoldKey.currentState.showSnackBar(
    //                                       SnackBar(
    //                                         content: Text(
    //                                             'Distance Calculated Sucessfully'),
    //                                       ),
    //                                     );
    //                                   } else {
    //                                     _scaffoldKey.currentState.showSnackBar(
    //                                       SnackBar(
    //                                         content: Text(
    //                                             'Error Calculating Distance'),
    //                                       ),
    //                                     );
    //                                   }
    //                                 });
    //                               }
    //                             : null,
    //                         color: Colors.red,
    //                         shape: RoundedRectangleBorder(
    //                           borderRadius: BorderRadius.circular(5.0),
    //                         ),
    //                         child: Padding(
    //                           padding: const EdgeInsets.all(8.0),
    //                           child: Text(
    //                             'Show Route'.toUpperCase(),
    //                             style: TextStyle(
    //                               color: Colors.white,
    //                               fontSize: 15.0,
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //         // Show current location button
    //         SafeArea(
    //           child: Align(
    //             alignment: Alignment.bottomLeft,
    //             child: Padding(
    //               padding: const EdgeInsets.only(left: 5.0, bottom: 25.0),
    //               child: ClipOval(
    //                 child: Material(
    //                   color: Colors.orange[100], // button color
    //                   child: InkWell(
    //                     splashColor: Colors.orange, // inkwell color
    //                     child: SizedBox(
    //                       width: 56,
    //                       height: 56,
    //                       child: Icon(Icons.my_location),
    //                     ),
    //                     onTap: () {
    //                       mapController.animateCamera(
    //                         CameraUpdate.newCameraPosition(
    //                           CameraPosition(
    //                             target: LatLng(
    //                               _currentPosition.latitude,
    //                               _currentPosition.longitude,
    //                             ),
    //                             zoom: 18.0,
    //                           ),
    //                         ),
    //                       );
    //                     },
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //         // Pre-confirmation

    //         // SafeArea(
    //         //   child: Align(
    //         //     alignment: Alignment.bottomRight,
    //         //     child: Padding(
    //         //       padding: const EdgeInsets.only(right: 5.0, bottom: 5.0),
    //         //       child: ClipRRect(
    //         //         child: Material(
    //         //           color: Colors.red[900], // button color
    //         //           child: InkWell(
    //         //             splashColor: Colors.red, // inkwell color
    //         //             child: SizedBox(
    //         //               width: 70,
    //         //               height: 50,
    //         //               child: Icon(Icons.done_all),
    //         //             ),
    //         //             onTap: () {
    //         //               showDialog(
    //         //                   context: context,
    //         //                   child: new AlertDialog(
    //         //                     title: new Text("Comfirm"),
    //         //                     content: new Text(
    //         //                         "From $_startAddress to $_destinationAddress"),
    //         //                     actions: <Widget>[
    //         //                       new FlatButton(
    //         //                         child: new Text("Close"),
    //         //                         onPressed: () {
    //         //                           Navigator.of(context).pop();
    //         //                         },
    //         //                       ),
    //         //                       new FlatButton(
    //         //                         child: new Text("OK"),
    //         //                         //เมื่อแตะปุ่มจะส่งค่าไปแมท
    //         //                         onPressed: () async {
    //         //                           await routeDBS.createItem(
    //         //                             RouteModel(
    //         //                               userID: "ddddd",
    //         //                               startLat: startLat,
    //         //                               startLng: startLng,
    //         //                               destLat: destLat,
    //         //                               destLng: destLng,
    //         //                               totalDistance: totalDistance,
    //         //                             ),
    //         //                           );
    //         //                           //Navigator.of(context).pop();

    //         //                           print('Distance: $totalDistance');
    //         //                           // print('START COORDINATES: $startCoordinates');
    //         //                           print(
    //         //                               'START COORDINATES: $startLat, $startLng');
    //         //                           // print('DESTINATION COORDINATES: $destinationCoordinates');
    //         //                           print(
    //         //                               'DESTINATION COORDINATES: $destLat, $destLng');
    //         //                         }, //ส่งไปแมทใน firebase
    //         //                       ),
    //         //                     ],
    //         //                   ));
    //         //             },
    //         //           ),
    //         //         ),
    //         //       ),
    //         //     ),
    //         //   ),
    //         // ),
    //       ],
    //     ),
    //   ),
    // );
  }
}

//เมื่อแตะปุ่มจะส่งค่าไปแมท
// onTap: () async {
//   await routeDBS.createItem(
//     RouteModel(
//       userID: "ddddd",
//       startLat: startLat,
//       startLng: startLng,
//       destLat: destLat,
//       destLng: destLng,
//       totalDistance: totalDistance,
//     ),
//   );
//   print('Distance: $totalDistance');
//   // print('START COORDINATES: $startCoordinates');
//   print('START COORDINATES: $startLat, $startLng');
//   // print('DESTINATION COORDINATES: $destinationCoordinates');
//   print('DESTINATION COORDINATES: $destLat, $destLng');
// }, //ส่งไปแมทใน firebase
