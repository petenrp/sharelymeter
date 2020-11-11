import "package:firebase_helpers/firebase_helpers.dart";

class RouteModel extends DatabaseItem {
  // final String id;
  final String userID;
  final double startLat;
  final double startLng;
  final double destLat;
  final double destLng;
  final double totalDistance;
  final String startAddress;
  final String destinationAdress;

  RouteModel(
      {this.userID,
      this.startLat,
      this.startLng,
      this.destLat,
      this.destLng,
      this.totalDistance,
      this.startAddress,
      this.destinationAdress})
      : super(userID);

  factory RouteModel.fromMap(Map data) {
    return RouteModel(
      userID: data['userID'],
      startLat: data['startLat'],
      startLng: data['startLng'],
      destLat: data['desLat'],
      destLng: data['desLng'],
      totalDistance: data['totalDistance'],
      startAddress: data['startAddress'],
      destinationAdress: data['destinationAdress'],
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
      startAddress: data['startAddress'],
      destinationAdress: data['destinationAdress'],
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
      "startAddress": startAddress,
      "destinationAdress": destinationAdress,
    };
  }
}
