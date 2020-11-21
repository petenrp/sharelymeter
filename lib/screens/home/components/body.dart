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
      child: Padding(
        padding: EdgeInsets.only(top: 25, bottom: 0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: HeaderWithSearchBox(
                  size: size,
                ),
              ),
              // Positioned(
              //   top: size.height * 0.22,
              //   child:
              Container(
                height: size.height * 0.85,
                child: Padding(
                  // padding: EdgeInsets.symmetric(
                  //   horizontal: kDefaultPadding,
                  // ),
                  padding: EdgeInsets.only(
                    top: size.height * 0.22,
                    left: kDefaultPadding,
                    right: kDefaultPadding,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: ScheduleRide(
                            size: size,
                            dateAndTime: "08-12-2020, 10:00",
                            startPoint:
                                "King's Mongkutt University of Technology Thonburi",
                            destinationPoint:
                                "Central Rama II",
                            partnerFirstname: "Panusron",
                            partnerPhoneNumber: "0800420423",
                            status: "On waiting",
                            press: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
