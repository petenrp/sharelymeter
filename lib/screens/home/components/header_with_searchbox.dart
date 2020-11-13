import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sharelymeter/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HeaderWithSearchBox extends StatelessWidget {
  const HeaderWithSearchBox({
    Key key,
    @required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.uid;
    CollectionReference users =
        FirebaseFirestore.instance.collection('userInfo');

    return Container(
        child: Container(
      child: FutureBuilder<DocumentSnapshot>(
        future: users.doc(user.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            print("sth went wrong");
            return Text("something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            String name = data['firstname'] + "  " + data['lastname'];
            print("Full Name: ${data['firstname']} ${data['lastname']}");
            // return Text("Full Name: ${data['firstname']} ${data['lastname']}");

            return Container(
              margin: EdgeInsets.only(bottom: kDefaultPadding * 2.5),
              //20% of the screen
              height: size.height * 0.2,
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: kDefaultPadding,
                      right: kDefaultPadding,
                    ),
                    height: size.height * 0.2 - 27,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(36),
                        bottomLeft: Radius.circular(36),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Hi! ' + data['firstname'] + '\n',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    TextSpan(
                                      text:
                                          'Find sharely partner on your route',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Expanded(
                                child: Image.asset("assets/images/logo.png"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                      padding:
                          EdgeInsets.symmetric(horizontal: kDefaultPadding),
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 10),
                            blurRadius: 50,
                            color: kPrimaryColor.withOpacity(0.2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              onChanged: (value) {},
                              decoration: InputDecoration(
                                hintText: "Where you would like to go?",
                                hintStyle: TextStyle(color: kSecondaryColor),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/search.svg',
                            height: 25.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          print("Loading");
          return Text("Loading");
        },
      ),
    ));

    // return Container(
    //
    //   margin: EdgeInsets.only(bottom: kDefaultPadding * 2.5),
    //   //20% of the screen
    //   height: size.height * 0.2,
    //   child: Stack(
    //     children: <Widget>[
    //       Container(
    //         padding: EdgeInsets.only(
    //           left: kDefaultPadding,
    //           right: kDefaultPadding,
    //         ),
    //         height: size.height * 0.2 - 27,
    //         decoration: BoxDecoration(
    //           color: kPrimaryColor,
    //           borderRadius: BorderRadius.only(
    //             bottomRight: Radius.circular(36),
    //             bottomLeft: Radius.circular(36),
    //           ),
    //         ),
    //         child: Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: Column(
    //             children: <Widget>[
    //               Row(
    //                 children: <Widget>[
    //                   RichText(
    //                     text: TextSpan(
    //                       children: [
    //                         TextSpan(
    //                           text: 'Hi! ' + 'Jaehyun' + '\n',
    //                           style: Theme.of(context)
    //                               .textTheme
    //                               .headline4
    //                               .copyWith(
    //                                 color: Colors.white,
    //                                 fontWeight: FontWeight.bold,
    //                               ),
    //                         ),
    //                         TextSpan(
    //                           text: 'Find sharely partner on your route',
    //                           style: TextStyle(
    //                             fontSize: 16,
    //                             color: Colors.white,
    //                             fontWeight: FontWeight.normal,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                   Spacer(),
    //                   Expanded(
    //                     child: Image.asset("assets/images/logo.png"),
    //                   ),
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //       Positioned(
    //         bottom: 0,
    //         left: 0,
    //         right: 0,
    //         child: Container(
    //           alignment: Alignment.center,
    //           margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
    //           padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
    //           height: 54,
    //           decoration: BoxDecoration(
    //             color: Colors.white,
    //             borderRadius: BorderRadius.circular(20),
    //             boxShadow: [
    //               BoxShadow(
    //                 offset: Offset(0, 10),
    //                 blurRadius: 50,
    //                 color: kPrimaryColor.withOpacity(0.2),
    //               ),
    //             ],
    //           ),
    //           child: Row(
    //             children: <Widget>[
    //               Expanded(
    //                 child: TextField(
    //                   onChanged: (value) {},
    //                   decoration: InputDecoration(
    //                     hintText: "Where you would like to go?",
    //                     hintStyle: TextStyle(color: kSecondaryColor),
    //                     enabledBorder: InputBorder.none,
    //                     focusedBorder: InputBorder.none,
    //                   ),
    //                 ),
    //               ),
    //               SvgPicture.asset(
    //                 'assets/icons/search.svg',
    //                 height: 25.0,
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
