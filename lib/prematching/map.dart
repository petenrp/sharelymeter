import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
// Stores the Google Maps API Key
import 'package:sharelymeter/googlemapapi.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../models/route.dart';
import 'package:sharelymeter/shared/constants.dart';

import '../screens/add/component/confirm_screen.dart';

//khem
import 'package:sharelymeter/database/dbformatching.dart';
import 'package:firebase_auth/firebase_auth.dart';

//SocketIO
import 'package:socket_io/socket_io.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

//Google Map Autocomplete
// import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:uuid/uuid.dart';
import 'package:sharelymeter/prematching/address_search.dart';
import 'package:sharelymeter/prematching/place_service.dart';

import 'dart:math' show cos, sqrt, asin;

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

  String _streetNumber = '';
  String _startAddress = 'KMUTT';
  String _destinationAddress = 'Central rama 2';
  String _placeDistance = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  String startAddress = '';
  String destinationAdress = '';

  String partner = '';
  String estimatedPrice = '';
  String distance = '';

  bool markersPinned = false;
  bool showPlaceForm = true;
  bool matchingConfirmRequest = false;
  bool showCancelForm = false;

  double sLat = 0;
  double sLng = 0;
  double dLat = 0;
  double dLng = 0;

  double startLat = 0;
  double startLng = 0;
  double destLat = 0;
  double destLng = 0;
  double totalDistance = 0;
  String userID = "Test";

  Set<Marker> markers = {};

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //Autocomplete
  final _controller = TextEditingController();
  String _locationName = '';
  String _streeNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';

  List<String> detailPoints = [];

  IO.Socket socket =
      IO.io('https://afternoon-tor-56476.herokuapp.com', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  @override
  void dispose() {
    _controller.dispose();
    this.socket.connect();
    super.dispose();
  }

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
          // hintText: hint,
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
    } catch (e) {
      print(e);
    }
  }

  Future<Position> _getPositionFromAddress(_address) async {
    List<Placemark> placeMark =
        await _geolocator.placemarkFromAddress(_address);
    if (placeMark != null) {
      Position coordinate = placeMark[0].position;
      return coordinate;
    }
    return null;
  }

  Future<void> _pinMarker(Position position,
      {title = '', address = '', icon = BitmapDescriptor.defaultMarker}) async {
    Marker marker = Marker(
      markerId: MarkerId('$position'),
      position: LatLng(
        position.latitude,
        position.longitude,
      ),
      infoWindow: InfoWindow(
        title: title,
        snippet: address,
      ),
      icon: icon,
    );

    print('added');
    markers.add(marker);
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

        List<Marker> wayPoints = [
          Marker(
              markerId: MarkerId('13.6653073,100.4654094'),
              position: LatLng(13.6653073, 100.4654094),
              icon: BitmapDescriptor.defaultMarker),
          Marker(
              markerId: MarkerId('13.6612775,100.4618654'),
              position: LatLng(13.6612775, 100.4618654),
              icon: BitmapDescriptor.defaultMarker)
        ];

        startLat = startCoordinates.latitude;
        startLng = startCoordinates.longitude;
        destLat = destinationCoordinates.latitude;
        destLng = destinationCoordinates.longitude;

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);
        // wayPoints.forEach((element) {
        //   markers.add(element);
        // });

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

        await _createPolylines([startCoordinates, destinationCoordinates]);

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
  _createPolylines(List<Position> positions) async {
    polylineCoordinates.clear();
    polylinePoints = PolylinePoints();

    final start = positions[0];
    final destination = positions[3];

    final point2 = '' +
        positions[1].latitude.toString() +
        ',' +
        positions[1].longitude.toString();
    final point3 = '' +
        positions[2].latitude.toString() +
        ',' +
        positions[2].longitude.toString();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        GmapAPI.API_KEY, // Google Maps API Key
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(destination.latitude, destination.longitude),
        travelMode: TravelMode.driving,
        wayPoints: [
          PolylineWayPoint(location: point2),
          PolylineWayPoint(location: point3),
        ]);

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

    this.socket.on('connect', (_) {
      print('Connected');
      this.socket.emit('request',
          '{"src":{"lat":13.6494925,"lng":100.4953804},"dest":{"lat":13.664666,"lng":100.441415}}');
    });

    this.socket.on('cancel', (value) async {
      resetBoolean();
    });

    this.socket.on('result', (value) async {
      // print(value);
      try {
        Map<String, dynamic> result = jsonDecode(value);
        detailPoints =
            (result['points'] as List)?.map((item) => item as String)?.toList();

        List<Position> positions = (result['path'] as List)
            ?.map((item) => Position(
                  latitude: item['lat'] as double,
                  longitude: item['lng'] as double,
                ) as Position)
            ?.toList();

        markers.clear();

        positions.forEach((p) async {
          await _pinMarker(p);
        });

        await _createPolylines(positions);

        String rDistance = result['distance'];
        String rEstimatedPrice = result['estimatedPrice'];
        String rPartner = result['partner'];

        setState(() {
          showPlaceForm = false;
          matchingConfirmRequest = true;
          distance = rDistance;
          estimatedPrice = rEstimatedPrice;
          partner = rPartner;
        });
      } catch (e) {
        print(e);
      }
    });

    this.socket.connect();
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
          showPlaceForm ? buildForm(width, context) : Text(""),
          showCancelForm
              ? SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: showPlaceForm
                        ? RaisedButton(
                            onPressed: () {
                              resetBoolean();
                            },
                            color: kSecondaryColor,
                            child: Text("Cancel Matching",
                                style: TextStyle(color: Colors.white)),
                          )
                        : null,
                  ),
                )
              : Text(""),
          // buildButtons(),
          matchingConfirmRequest ? buildDetailBox(width, context) : Text(""),
        ],
      ),
      // floatingActionButton: buildFloatingActionButton(context),
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
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
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("No"),
                    ),
                    FlatButton(
                      onPressed: () {
                        destinationAdress = _destinationAddress;
                        startAddress = _startAddress;
                        final FirebaseAuth auth = FirebaseAuth.instance;
                        Future<void> inputData() async {
                          final User user = auth.currentUser;
                          final uid = user.uid;
                          return await DatabaseServices(uid: user.uid)
                              .addingRoutingData(
                            destLat,
                            destLng,
                            destinationAdress,
                            startAddress,
                            startLat,
                            startLng,
                            totalDistance,
                            userID,
                          );
                        }

                        inputData();

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
                  ],
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.done_all),
        backgroundColor: Colors.red);
  }

  SafeArea buildButtons() {
    return SafeArea(
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
    );
  }

  Future<void> formButtonHandler() async {
    if (!markersPinned) {
      await pinMarkersByAddresses();
    } else {
      print("Finding Match");
      setState(() {
        // findingMatch = true;
        showPlaceForm = false;
        matchingConfirmRequest = true;
      });
    }
    // _calculateDistance().then((isCalculated) {
    //   if (isCalculated) {
    //     _scaffoldKey.currentState.showSnackBar(
    //       SnackBar(
    //         content: Text(
    //             'Distance Calculated Sucessfully'),
    //       ),
    //     );
    //   } else {
    //     _scaffoldKey.currentState.showSnackBar(
    //       SnackBar(
    //         content: Text(
    //             'Error Calculating Distance'),
    //       ),
    //     );
    //   }
    // });
  }

  Future pinMarkersByAddresses() async {
    setState(() {
      if (markers.isNotEmpty) markers.clear();
      if (polylines.isNotEmpty) polylines.clear();
      if (polylineCoordinates.isNotEmpty) polylineCoordinates.clear();
      _placeDistance = null;
    });

    try {
      Position _northeastCoordinates;
      Position _southwestCoordinates;

      Position startingPoint = await _getPositionFromAddress(_startAddress);
      await _pinMarker(startingPoint);

      Position destinationPoint =
          await _getPositionFromAddress(_destinationAddress);
      await _pinMarker(destinationPoint);

      print(markers);

      setState(() {
        markersPinned = true;
      });

      if (startingPoint.latitude <= destinationPoint.latitude) {
        _southwestCoordinates = startingPoint;
        _northeastCoordinates = destinationPoint;
      } else {
        _southwestCoordinates = destinationPoint;
        _northeastCoordinates = startingPoint;
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
          120.0,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void resetBoolean() {
    setState(() {
      markersPinned = false;
      showPlaceForm = true;
      matchingConfirmRequest = false;
    });
  }

  SafeArea buildLayout(double width, Widget child,
      {alignment = Alignment.topCenter}) {
    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
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
                child: child),
          ),
        ),
      ),
    );
  }

  SafeArea buildForm(double width, BuildContext context) {
    return buildLayout(
        width,
        Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text(
            'Places',
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(height: 5),
          _textField(
              label: 'Start',
              hint: 'Choose starting point',
              prefixIcon: Icon(Icons.location_city_outlined),
              suffixIcon: IconButton(
                icon: Icon(Icons.my_location),
                onPressed: () async {
                  //  startAddressController.text = _currentAddress;
                  //  _startAddress = _currentAddress;
                  final sessionToken = Uuid().v4();
                  final Suggestion result = await showSearch(
                    context: context,
                    delegate: AddressSearch(sessionToken),
                  );
                  // This will change the text displayed in the TextField
                  if (result != null) {
                    final placeDetails = await PlaceApiProvider(sessionToken)
                        .getPlaceDetailFromId(result.placeId);
                    setState(() {
                      _controller.text = result.description;
                      _streetNumber = placeDetails.streetNumber;
                      _street = placeDetails.street;
                      _city = placeDetails.city;
                      _zipCode = placeDetails.zipCode;
                    });
                  }
                },
              ),
              controller: startAddressController,
              width: width,
              locationCallback: (String value) {
                setState(() {
                  _startAddress = value;
                });
                resetBoolean();
              }),
          SizedBox(height: 5),
          _textField(
              label: 'Destination',
              hint: 'Choose destination',
              prefixIcon: Icon(Icons.location_on_rounded),
              controller: destinationAddressController,
              width: width,
              locationCallback: (String value) {
                setState(() {
                  _destinationAddress = value;
                });
                resetBoolean();
              }),
          SizedBox(height: 5),
          SizedBox(height: 0),
          RaisedButton(
            onPressed: (_startAddress != '' && _destinationAddress != '')
                ? () async {
                    await formButtonHandler();
                  }
                : null,
            color: markersPinned ? kPrimaryColor : kSecondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                !markersPinned
                    ? 'pin your location'.toUpperCase()
                    : 'find your match'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ]));
  }

  SafeArea buildDetailBox(double width, BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: kDefaultPadding * 0.5),
          child: buildDetailConfirmation(size, detailPoints),
        ),
      ),
    );
  }

  Widget buildDetailConfirmation(
    Size size,
    List<String> waypoints,
  ) {
    const dateAndTime = 'date and time';
    List<String> points = [
      waypoints[0],
      null,
      waypoints[1],
      null,
      waypoints[2],
      null,
      waypoints[3],
    ];
    // const status = '';
    return Wrap(children: [
      Container(
        constraints: BoxConstraints(
          minHeight: 350,
        ),
        // height: size.height * 0.28,
        width: size.width - (4 * kDefaultPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          // boxShadow: [
          //   BoxShadow(
          //     offset: Offset(0, 17),
          //     blurRadius: 24,
          //     spreadRadius: -14,
          //     color: kShadowColor,
          //   ),
          // ],
        ),
        //information
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //date and time
            Container(
              padding: EdgeInsets.only(
                top: kDefaultPadding,
                left: kDefaultPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: Icon(
                      FlutterIcons.schedule_mdi,
                      size: 30,
                      color: kLightGreyColor,
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                        left: kDefaultPadding / 2,
                      ),
                      child: Text(
                        dateAndTime,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ))
                ],
              ),
            ),
            for (var point in points)
              (point == null
                  ? Container(
                      margin: EdgeInsets.only(
                        top: kDefaultPadding / 4,
                        left: kDefaultPadding + 12.5,
                      ),
                      height: 5,
                      width: 5,
                      color: kShadowColor,
                    )
                  : Container(
                      margin: EdgeInsets.only(
                        top: kDefaultPadding / 4,
                        left: kDefaultPadding + 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Icon(
                              FlutterIcons.radio_button_unchecked_mdi,
                              size: 20,
                              color: kLightGreyColor,
                            ),
                          ),
                          Container(
                            width: 270,
                            margin: EdgeInsets.only(
                              left: kDefaultPadding * 0.75,
                            ),
                            child: Text(
                              point,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
            //partner
            Container(
              margin: EdgeInsets.only(
                top: kDefaultPadding / 4,
                left: kDefaultPadding,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  child: Icon(
                    FlutterIcons.supervisor_account_mdi,
                    size: 30,
                    color: kLightGreyColor,
                  ),
                ),
                Container(
                    width: 265,
                    margin: EdgeInsets.only(
                      left: kDefaultPadding * 0.75,
                    ),
                    child: Text(
                      partner,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ))
              ]),
            ),
            // Cost
            Container(
              margin: EdgeInsets.only(
                top: kDefaultPadding / 4,
                left: kDefaultPadding,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  child: Icon(
                    FlutterIcons.car_alt_faw5s,
                    size: 30,
                    color: kLightGreyColor,
                  ),
                ),
                Container(
                  width: 265,
                  margin: EdgeInsets.only(
                    left: kDefaultPadding * 0.75,
                  ),
                  child: Text(
                    distance,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ]),
            ),
            // Cost
            Container(
              margin: EdgeInsets.only(
                top: kDefaultPadding / 4,
                left: kDefaultPadding,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  child: Icon(
                    FlutterIcons.money_bill_alt_faw5,
                    size: 30,
                    color: kLightGreyColor,
                  ),
                ),
                Container(
                  width: 265,
                  margin: EdgeInsets.only(
                    left: kDefaultPadding * 0.75,
                  ),
                  child: Text(
                    estimatedPrice,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ]),
            ),
            Container(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.red,
                      onPressed: () {
                        resetBoolean();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    RaisedButton(
                      color: Colors.green,
                      onPressed: () {
                        resetBoolean();
                      },
                      child: Text(
                        "Confirm",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ]),
            ),
            //status
            // Container(
            //   margin: EdgeInsets.only(
            //     top: kDefaultPadding / 4,
            //     left: kDefaultPadding + 5,
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     children: [
            //       Container(
            //         child: Icon(FlutterIcons.circle_mco,
            //             size: 20, color: Colors.orange),
            //       ),
            //       Container(
            //           width: 270,
            //           margin: EdgeInsets.only(
            //             left: kDefaultPadding * 0.75,
            //           ),
            //           child: Text(
            //             status,
            //             style: TextStyle(
            //               fontSize: 16,
            //               fontWeight: FontWeight.w500,
            //             ),
            //           ))
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    ]);
  }
}
