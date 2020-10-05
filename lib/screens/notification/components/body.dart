import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sharelymeter/screens/notification/components/notification_message.dart';
import 'package:sharelymeter/shared/constants.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
           buildNotificationItem(),
        ],
      ),
    );
  }
}

Container buildNotificationItem() {
  return Container(
    padding: EdgeInsets.only(
      top: kDefaultPadding,
      bottom: kDefaultPadding,
      left: kDefaultPadding,
      right: kDefaultPadding
    ),
    child: Column(
      children: <Widget>[
        NotificationMessage(
          startPoint: "King's Mongkutt University of Technology Thonburi",
          destinationPoint: "Siam Paragon",
          dateAndTime: "17-12-2020, 17:00",
          status: 0,
          press: () {},
        ),
        NotificationMessage(
          startPoint: "King's Mongkutt University of Technology Thonburi",
          destinationPoint: "Siam Paragon",
          dateAndTime: "18-12-2020, 17:00",
          status: 0,
          press: () {},
        ),
        NotificationMessage(
          startPoint: "King's Mongkutt University of Technology Thonburi",
          destinationPoint: "Siam Paragon",
          dateAndTime: "19-12-2020, 17:00",
          status: 0,
          press: () {},
        ),
        NotificationMessage(
          startPoint: "King's Mongkutt University of Technology Thonburi",
          destinationPoint: "Siam Paragon",
          dateAndTime: "20-12-2020, 17:00",
          status: 0,
          press: () {},
        ),
        NotificationMessage(
          startPoint: "King's Mongkutt University of Technology Thonburi",
          destinationPoint: "Siam Paragon",
          dateAndTime: "21-12-2020, 17:00",
          status: 0,
          press: () {},
        ),
        NotificationMessage(
          startPoint: "King's Mongkutt University of Technology Thonburi",
          destinationPoint: "Siam Paragon",
          dateAndTime: "22-12-2020, 17:00",
          status: 0,
          press: () {},
        ),
        NotificationMessage(
          startPoint: "King's Mongkutt University of Technology Thonburi",
          destinationPoint: "Siam Paragon",
          dateAndTime: "22-12-2020, 17:00",
          status: 0,
          press: () {},
        ),
      ]
    ),
  );
}
