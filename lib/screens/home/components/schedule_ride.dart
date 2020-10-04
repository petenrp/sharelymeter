import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sharelymeter/shared/constants.dart';

class ScheduleRide extends StatelessWidget {
  const ScheduleRide({
    Key key,
    @required this.size,
    this.dateAndTime,
    this.startPoint,
    this.destinationPoint,
    this.partnerFirstname,
    this.partnerLastname, 
    this.press,
  }) : super(key: key);

  final Size size;
  final String startPoint, destinationPoint, dateAndTime, partnerFirstname, partnerLastname;
  final Function press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: press,
        child: Container(
        padding: EdgeInsets.all(kDefaultPadding),
        decoration: BoxDecoration(
          color: kTertiaryColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 17),
              blurRadius: 24,
              spreadRadius: -14,
              color: kLightTertiaryColor,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                bottom: kDefaultPadding / 4,
              ),
              child: Text(
                'Schedule ride : ', 
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            //white area
            Container(
              height: size.height * 0.25,
              width: size.width - (4 * kDefaultPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 17),
                    blurRadius: 24,
                    spreadRadius: -14,
                    color: kShadowColor,
                  ),
                ],
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
                            left: kDefaultPadding/2,
                          ),
                          child: Text(
                            dateAndTime,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                  //start point
                  Container(
                    margin: EdgeInsets.only(
                      top: kDefaultPadding/4,
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
                            startPoint,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                  //line
                  Container(
                    margin: EdgeInsets.only(
                      top: kDefaultPadding/4,
                      left: kDefaultPadding + 12.5,
                    ),
                    height: 30,
                    width: 5,
                    color: kShadowColor,
                  ),
                  //destination point
                  Container(
                    margin: EdgeInsets.only(
                      top: kDefaultPadding/4,
                      left: kDefaultPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Icon(
                            FlutterIcons.location_on_mdi,
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
                            destinationPoint,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        )
                        
                      ],
                    ),
                  ),
                  //partner
                  Container(
                    margin: EdgeInsets.only(
                      top: kDefaultPadding/4,
                      left: kDefaultPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
                            partnerFirstname + " " + partnerLastname,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        )
                      ]
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}