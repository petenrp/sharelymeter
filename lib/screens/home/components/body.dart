import 'package:flutter/material.dart';
import 'package:sharelymeter/constants.dart';
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
                      Container(
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
                            Container(
                              height: size.height * 0.15,
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
                            ),
                          ],
                        ),
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