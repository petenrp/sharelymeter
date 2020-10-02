import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sharelymeter/constants.dart';

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
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                20
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/notification_bell.svg'),
              ],
            ),
          )
        ],
      ),
    );
}
