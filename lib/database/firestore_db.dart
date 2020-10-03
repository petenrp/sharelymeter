import 'package:firebase_helpers/firebase_helpers.dart';
import 'package:sharelymeter/models/route.dart';

DatabaseService<RouteModel> routeDBS = DatabaseService<RouteModel>(
    "MatchingRoute",
    fromDS: (userID, data) => RouteModel.fromDS(userID, data),
    toMap: (route) => route.toMap());
