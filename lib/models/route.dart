import "package:firebase_helpers/firebase_helpers.dart";

class RouteModel extends DatabaseItem {
  // final String id;
  final String userID;
  final double startLat;
  final double startLng;
  final double destLat;
  final double destLng;
  final double totalDistance;

  RouteModel(
      {this.userID,
      this.startLat,
      this.startLng,
      this.destLat,
      this.destLng,
      this.totalDistance})
      : super(userID);

  factory RouteModel.fromMap(Map data) {
    return RouteModel(
      //userID: data,
      startLat: data['startLat'],
      startLng: data['startLng'],
      destLat: data['desLat'],
      destLng: data['desLng'],
      totalDistance: data['totalDistance'],
    );
  }

  factory RouteModel.fromDS(String userID, Map<String, dynamic> data) {
    return RouteModel(
      // id: id,
      userID: userID,
      startLat: data['startLat'],
      startLng: data['startLng'],
      destLat: data['desLat'],
      destLng: data['desLng'],
      totalDistance: data['totalDistance'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // "id": id,
      "userID": userID,
      "startLat": startLat,
      "startLng": startLng,
      "destLat": destLat,
      "destLng": destLng,
      "totalDistance": totalDistance,
    };
  }
}
