import 'package:firebase_helpers/firebase_helpers.dart';
<<<<<<< HEAD
import '../models/route.dart';

DatabaseService<RouteModel> routeDBS = DatabaseService<RouteModel>(
    "MatchingRoute",
    fromDS: (userID, data) => RouteModel.fromDS(userID, data),
    toMap: (route) => route.toMap());
=======
import 'package:sharelymeter/models/route.dart';

DatabaseService<RouteModel> routeDBS = DatabaseService<RouteModel>(
  "MatchingRoute",
  fromDS: (userID, data) => RouteModel.fromDS(userID, data),
  toMap: (route) => route.toMap()
);
>>>>>>> master
