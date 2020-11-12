import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharelymeter/models/userInformation.dart';

class DatabaseServices{
  final String uid;
  DatabaseServices({this.uid});

  //Collocetion reference
  final CollectionReference matchingRouteInfo = FirebaseFirestore.instance.collection('RoutingData'); //Khemmy

  Future addingRoutingData(double destLat, double destLng,String destinationAdress, String startAddress, double startLat, double startLng, double totalDistance, String userID) async {
    return await matchingRouteInfo.doc(uid).set(
        {
          'destLat' : destLat,
          'destLng' : destLng,
          'destinationAdress' : destinationAdress,
          'startAddress' : startAddress,
          'startLat' : startLat,
          'startLng' : startLng,
          'totalDistance' : totalDistance,
          'userID' : userID,
        }
    );
  }
}