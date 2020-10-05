import 'package:flutter/material.dart';
import 'package:sharelymeter/screens/home/components/schedule_ride.dart';
import 'package:sharelymeter/shared/constants.dart';
import 'package:sharelymeter/screens/home/components/header_with_searchbox.dart';
//import 'package:sharelymeter/screens/home/components/title_with_more_button.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //total height and width of the screen
    Size size = MediaQuery.of(context).size;
    //enable scrolling on small device
    return SafeArea(
        child: Column(
        children: <Widget>[
          HeaderWithSearchBox(size: size),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    children: <Widget>[
                      ScheduleRide(
                        size: size,
                        dateAndTime: "18-12-2020, 18:00",
                        startPoint: "King's Mongkutt University of Technology Thonburi",
                        destinationPoint: "King's Mongkutt University of Technology Thonburi",
                        partnerFirstname: "Naruhpak",
                        partnerLastname: " Rotchanakanokchok",
                        press: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}