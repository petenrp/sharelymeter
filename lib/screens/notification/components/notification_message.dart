import 'package:flutter/material.dart';
import 'package:sharelymeter/shared/constants.dart';
class NotificationMessage extends StatelessWidget {
  NotificationMessage({
    Key key,
    this.startPoint,
    this.destinationPoint,
    this.dateAndTime,
    this.status,
    this.press,
  }) : super(key: key);
  final String startPoint, destinationPoint, dateAndTime;
  final int status;
  final Function press;
  final STATUS_MESSAGES = {
    0: " has been canceled",
    1: " has been accepted",
    2: " has been time-out",
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        margin: EdgeInsets.only(
          bottom: kDefaultPadding/2,
        ),
        padding: EdgeInsets.only(
          left: kDefaultPadding,
          right: kDefaultPadding,
        ),
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            20
          ),
        ),
        child: Row(
          children: [
            Container(
              child: Image.asset(
                "assets/images/logo.png",
                height: 50,
              ),
            ),
            Container(
              width: 280,
              padding: EdgeInsets.only(
                top: kDefaultPadding,
                left: kDefaultPadding,
              ),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan (
                      text: "Your matching request ",
                      style: TextStyle(
                      fontSize: 14,
                      color: kTextColor,
                      ),
                      children: <TextSpan> [
                        TextSpan (
                          text: "from ",
                          style: TextStyle(
                            fontSize: 14,
                            color: kTextColor,
                          ),
                        ),
                        TextSpan(
                          // text: "King 's Mongkutt University of Technology Thonburi",
                          text: startPoint,
                          style: TextStyle(
                            fontSize: 14,
                            color: kTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: " to ",
                          style: TextStyle(
                            fontSize: 14,
                            color: kTextColor,
                          ),
                        ),
                        TextSpan(
                          // text: "Siam Paragon",
                          text: destinationPoint,
                          style: TextStyle(
                            fontSize: 14,
                            color: kTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: " on ",
                          style: TextStyle(
                            fontSize: 14,
                            color: kTextColor,
                          ),
                        ),
                        TextSpan(
                          // text: "25-12-2020, 18:00",
                          text: dateAndTime,
                          style: TextStyle(
                            fontSize: 14,
                            color: kTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        TextSpan(
                          // text: " has been accepted",
                          text: STATUS_MESSAGES[status],
                          style: TextStyle(
                            fontSize: 14,
                            color: kTextColor,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}