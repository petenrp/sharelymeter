import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
// Stores the Google Maps API Key
import 'package:sharelymeter/googlemapapi.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../models/route.dart';
import 'package:sharelymeter/shared/constants.dart';
import 'dart:math';
import 'dart:ui' as ui;

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

enum MatchingStatus {
  WaitingForMatching,
  RequestConfirmation,
  WaitingForConfirmation,
  NoOneOnTaxiYet,
  OneUserOnTaxi,
  TwoUserOnTaxi,
  OneUserDownTaxi,
  TwoUserDownTaxi,
}

enum PointStatus {
  Unreached,
  Reached
}

class PointFare {
  PointFare(
    this.status,
    this.text,
    this.fare,
  );

  String text;
  int fare;
  PointStatus status;
}

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
  BitmapDescriptor partnerIcon;
  Marker partnerMarker;
  MatchingStatus travelingStatus = MatchingStatus.RequestConfirmation;

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

  int _taxiMetreFare = 0;

  List<int> travelingFares = [];
  List<PointStatus> pointStatuses = [];

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final metreFareController = TextEditingController();

  String startAddress = '';
  String destinationAdress = '';

  String partner = '';
  String estimatedPrice = '';
  String distance = '';

  bool markersPinned = false;
  bool showPlaceForm = true;
  bool showTravelingDetail = false;
  bool matchingConfirmed = false;
  bool userOnTaxi = false;

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

  Widget _textField(
      {TextEditingController controller,
      String label,
      String hint,
      double width,
      Icon prefixIcon,
      Widget suffixIcon,
      Function(String) locationCallback,
      TextInputType keyboardType = TextInputType.text}) {
    return Container(
      width: width * 0.8,
      child: TextField(
        keyboardType: keyboardType,
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

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
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

  Future<Marker> _pinMarker(Position position,
      {title = '',
      address = '',
      icon = BitmapDescriptor.defaultMarker,
      zIndex = 0.0,
      String id = ''}) async {
    if (id == '') id = '$position';
    markers.removeWhere((e) => e.markerId.value == id);

    Marker marker = Marker(
      markerId: MarkerId(id),
      position: LatLng(
        position.latitude,
        position.longitude,
      ),
      infoWindow: InfoWindow(
        title: title,
        snippet: address,
      ),
      icon: icon,
      zIndex: zIndex,
    );

    print('added');
    markers.add(marker);
    setState(() {});
    return marker;
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

  Future<void> onPartnerMove(value) async {
    Map<String, dynamic> result = jsonDecode(value);
    print('pinning');

    double lat = result['lat'] as double;
    double lng = result['lng'] as double;

    Position newPosition = Position(latitude: lat, longitude: lng);

    Marker newMarker = await _pinMarker(newPosition,
        icon: partnerIcon, zIndex: 1.0, id: 'player');
    setState(() {
      partnerMarker = newMarker;
    });
  }

  Future<void> confirmTaxiMetre(value) async {
    Map<String, dynamic> decoded = jsonDecode(value);
    int taxi = decoded["taxi"] as int;
    buildTaxiMetreConfirmationDialog(
        this.context, "Confirm Taxi Metre", taxi.toString());
  }

  void onResult(value) async {
    Map<String, dynamic> result = jsonDecode(value);
    travelingFares = [-1, -1, -1, -1];
    pointStatuses = [
      PointStatus.Unreached,
      PointStatus.Unreached,
      PointStatus.Unreached,
      PointStatus.Unreached,
    ];

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

    double rightMost;
    double leftMost;
    double topMost;
    double bottomMost;

    positions.sort((a, b) => a.latitude.compareTo(b.latitude));

    rightMost = positions[3].latitude;
    leftMost = positions[0].latitude;

    positions.sort((a, b) => a.longitude.compareTo(b.longitude));

    topMost = positions[3].longitude;
    bottomMost = positions[0].longitude;

    double dy = rightMost - leftMost;
    double dx = topMost - bottomMost;

    double offset = -pow(dy / dx, 0.225) * 0.099 + 0.025;
    // - 0.065;
    double padding = 80 + 22.8 * pow(dy / dx, 1);

    print(offset);
    print(padding);
    print(dy);

    // Accommodate the two locations within the
    // camera view of the map
    await mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(
            rightMost + offset,
            topMost,
          ),
          southwest: LatLng(
            leftMost + offset,
            bottomMost,
          ),
        ),
        padding,
      ),
    );

    String rDistance = result['distance'];
    String rEstimatedPrice = result['estimatedPrice'];
    String rPartner = result['partner'];

    resetBoolean();
    setState(() {
      showPlaceForm = false;
      showTravelingDetail = true;
      travelingStatus = MatchingStatus.RequestConfirmation;
      distance = rDistance;
      estimatedPrice = rEstimatedPrice;
      partner = rPartner;
    });
  }

  Future<void> setPartnerIcon() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/partner.png', 100);
    setState(() {
      partnerIcon = BitmapDescriptor.fromBytes(markerIcon);
    });
  }

  Future<void> serverCancelMatching() async {
    buildInformationDialog(
        this.context, "Information", "Partner has canceled the matching.");
    // _scaffoldKey.currentState.showSnackBar(
    //   SnackBar(
    //     content: Text(
    //         'Partner has canceled the matching'),
    //   ),
    // );
    cancelMatching();
  }

  Future<void> showTaxiMetreDialog() async {
    buildTaxiMetreDialog(this.context, "Taxi Metre", "Please ");
  }

  void noOneOnTaxi() {
    setState((){
      userOnTaxi = false;
      travelingStatus = MatchingStatus.NoOneOnTaxiYet;
    });
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          'Matching Confirmed',
        ),
      ),
    );
  }

  void oneUserOnTaxi(bool isYou, int taxi) {
    setState(() {
      travelingStatus = MatchingStatus.OneUserOnTaxi;
      if(isYou) {
        userOnTaxi = true;
      }
      pointStatuses[0] = PointStatus.Reached;
      travelingFares[0] = taxi;
    });
  }

  void twoUserOnTaxi(bool isYou, int taxi) {
    setState(() {
      travelingStatus = MatchingStatus.TwoUserOnTaxi;
      if(isYou) {
        userOnTaxi = true;
      }
      pointStatuses[1] = PointStatus.Reached;
      travelingFares[1] = taxi;
    });
  }

  void oneUserDownTaxi(bool isYou, int taxi) {
    setState(() {
      travelingStatus = MatchingStatus.OneUserDownTaxi;
      if(isYou) {
        userOnTaxi = false;
      }
      pointStatuses[2] = PointStatus.Reached;
      travelingFares[2] = taxi;
    });
  }

  void twoUserDownTaxi(bool isYou, int taxi) {
    setState(() {
      travelingStatus = MatchingStatus.TwoUserDownTaxi;
      if(isYou) {
        userOnTaxi = false;
      }
      pointStatuses[3] = PointStatus.Reached;
      travelingFares[3] = taxi;
    });
  }

  Future<void> setStatus(value) async {
    Map<String, dynamic> decoded = jsonDecode(value);
    String status = decoded['status'] as String;
    switch (status) {
      case 'no_one_on_taxi':
        noOneOnTaxi();
        return;
      case 'one_user_on_taxi':
        bool isYou = decoded['isYou'] as bool;
        int taxi = decoded['taxi'] as int;
        oneUserOnTaxi(isYou, taxi);
        return;
      case 'two_user_on_taxi':
        bool isYou = decoded['isYou'] as bool;
        int taxi = decoded['taxi'] as int;
        twoUserOnTaxi(isYou, taxi);
        return;
      case 'one_user_down_taxi':
        bool isYou = decoded['isYou'] as bool;
        int taxi = decoded['taxi'] as int;
        oneUserDownTaxi(isYou, taxi);
        return;
      case 'two_user_down_taxi':
        bool isYou = decoded['isYou'] as bool;
        int taxi = decoded['taxi'] as int;
        twoUserDownTaxi(isYou, taxi);
        return;
    }
  }

  @override
  void initState() {
    super.initState();
    // _getCurrentLocation();
    setPartnerIcon();

    this.socket.on('connect', (_) {
      print('Connected');
      this.socket.emit('request',
          '{"src":{"lat":13.6494925,"lng":100.4953804},"dest":{"lat":13.664666,"lng":100.441415}}');
    });

    this.socket.on('cancel', (value) async {
      serverCancelMatching();
    });

    this.socket.on('result', (value) async {
      // print(value);
      try {
        onResult(value);
      } catch (e) {
        print(e);
      }
    });

    this.socket.on('partner_move', (value) async {
      try {
        await onPartnerMove(value);
      } catch (e) {
        print(e);
      }
    });

    this.socket.on('confirm_metre', (value) async {
      try {
        await confirmTaxiMetre(value);
      } catch (e) {
        print(e);
      }
    });

    this.socket.on('status', (value) async {
      try {
        setStatus(value);
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
          travelingStatus == MatchingStatus.WaitingForMatching
            ? buildMatchingInProcess() : Text(""),
          // buildButtons(),
          showTravelingDetail ? buildDetailBox(width, context) : Text(""),
        ],
      ),
      // floatingActionButton: buildFloatingActionButton(context),
    );
  }

  SafeArea buildMatchingInProcess() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: RaisedButton(
          onPressed: () {
            resetBoolean();
          },
          color: kSecondaryColor,
          child: Text("Cancel Matching", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // FloatingActionButton buildFloatingActionButton(BuildContext context) {
  //   return FloatingActionButton(
  //       onPressed: () {
  //         buildShowDialog(context);
  //       },
  //       child: Icon(Icons.done_all),
  //       backgroundColor: Colors.red);
  // }

  buildTaxiMetreConfirmationDialog(
      BuildContext context, String title, String content) async {
    Size size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      child: new AlertDialog(
        title: Text(title),
        content: Wrap(
          direction: Axis.vertical,
          children: [
            Container(
              child: Text("The current taxi metre is " + content),
            ),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FlatButton(
                color: Colors.red,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              SizedBox(width: 20),
              FlatButton(
                color: kPrimaryColor,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Confirm"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildTaxiMetreDialog(
      BuildContext context, String title, String content) async {
    Size size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      child: new AlertDialog(
        title: Text(title),
        content: Wrap(
          direction: Axis.vertical,
          children: [
            Container(
              child: Text(content),
            ),
            _textField(
                label: 'Taxi Metre Fare',
                hint: 'Please Enter Meter Fare',
                prefixIcon: Icon(Icons.local_taxi_rounded),
                controller: metreFareController,
                width: size.width * 0.75,
                locationCallback: (String value) {
                  setState(() {
                    _taxiMetreFare = int.parse(value);
                  });
                },
                keyboardType: TextInputType.number),
          ],
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
                child: Text("OK"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildInformationDialog(
      BuildContext context, String title, String content) async {
    showDialog(
      context: context,
      child: new AlertDialog(
        title: Text(title),
        content: Wrap(
          children: [
            Container(
              //color: Colors.amber,
              child: Text(content),
            ),
          ],
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
                child: Text("OK"),
              ),
            ],
          ),
        ],
      ),
    );
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
      // pin mark
      await pinMarkersByAddresses();
    } else {
      // find match
      setState(() {
        showPlaceForm = false;
        travelingStatus = MatchingStatus.WaitingForMatching;
        // matchingConfirmRequest = true;
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
      showTravelingDetail = false;
      travelingStatus = MatchingStatus.RequestConfirmation;
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
      Column(
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
        ],
      ),
    );
  }

  SafeArea buildDetailBox(double width, BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: kDefaultPadding * 0.5),
          child: buildTravelingDetail(size, pointStatuses, detailPoints, travelingFares),
        ),
      ),
    );
  }

  void cancelMatching() {
    polylineCoordinates.clear();
    pinMarkersByAddresses();
    resetBoolean();
  }

  Widget buildTravelingDetail(
    Size size,
    List<PointStatus> status,
    List<String> waypoints,
    List<int> fares,
  ) {
    const dateAndTime = 'date and time';
    List<PointFare> points = [
      PointFare(status[0], waypoints[0], fares[0]),
      null,
      PointFare(status[1], waypoints[1], fares[1]),
      null,
      PointFare(status[2], waypoints[2], fares[2]),
      null,
      PointFare(status[3], waypoints[3], fares[3]),
    ];
    // const status = '';

    List<Widget> actions = [];
    if (travelingStatus == MatchingStatus.RequestConfirmation) {
      actions = [
        RaisedButton(
          color: Colors.red,
          onPressed: () {
            cancelMatching();
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
            // resetBoolean();
            setState(() {
              travelingStatus = MatchingStatus.WaitingForConfirmation;
            });
          },
          child: Text(
            "Confirm",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ];
    } else if (travelingStatus == MatchingStatus.WaitingForConfirmation) {
      actions = <Widget>[
        RaisedButton(
          color: Colors.red,
          onPressed: () {
            cancelMatching();
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ];
    } else {

      String buttonText = "";
      bool disabled = false;
      
      if (userOnTaxi) {
        buttonText = "Get Down";
        if(travelingStatus == MatchingStatus.OneUserOnTaxi) {
          disabled = true;
        }
      } else {
        if(travelingStatus == MatchingStatus.OneUserDownTaxi
          || travelingStatus == MatchingStatus.TwoUserDownTaxi) {
          buttonText = "Done";
        } else {
          buttonText = "Get In";
        }
      }

      actions = <Widget>[
        RaisedButton(
          color: kPrimaryColor,
          onPressed: disabled ? null : () {
            // Get In Taxi
          },
          child: Text(
            buttonText,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ];
    }


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
                              FlutterIcons.radio_button_checked_mdi,
                              size: 20,
                              color: point.status == PointStatus.Unreached 
                                ? kLightGreyColor: Colors.green,
                            ),
                          ),
                          Container(
                              width: 250,
                              margin: EdgeInsets.only(
                                left: kDefaultPadding * 0.75,
                                right: kDefaultPadding * 0.75,
                              ),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      point.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      point.fare == -1? '???': point.fare.toString() + ' Baht',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ])),
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
            // Actions
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions,
              ),
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
