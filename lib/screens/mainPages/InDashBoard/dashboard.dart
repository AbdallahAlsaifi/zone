import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/paymentProcess/pzcoin.dart';
import 'package:zone/screens/mainPages/InDashBoard/chats/chat.dart';
import 'package:zone/screens/mainPages/InDashBoard/chats/chatScreen.dart';
import 'package:zone/screens/mainPages/InDashBoard/favorites/favorites.dart';
import 'package:zone/screens/mainPages/InDashBoard/myOffers.dart';
import 'package:zone/screens/mainPages/InDashBoard/support.dart';
import 'package:zone/screens/mainPages/InDashBoard/withdrawal.dart';
import 'package:zone/screens/settingsScreens/userSettings.dart';
import '../../../widgets/AdditionalWidgets.dart';

class dashboard extends StatefulWidget {
  const dashboard({Key? key}) : super(key: key);

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  int profit = 4, cost = 23, verification = 44, stints = 55, overAllRating = 1;
  double rateCount = 0.2;
  double userBalance = 1;

  @override
  Widget build(BuildContext context) {
    List<dashBoardContainers> x = [
      dashBoardContainers(
          'Chat',
          mainChatsScreen(),
          Icon(
            Icons.chat,
            color: primaryColor,
          )),
      dashBoardContainers(
          'My offers',
          myOffers(),
          Icon(
            Icons.local_offer,
            color: primaryColor,
            size: 50,
          )),
      dashBoardContainers(
          'Withdraw',
          withdraw(),
          Icon(
            Icons.monetization_on,
            color: primaryColor,
            size: 50,
          )),
      dashBoardContainers(
          'Settings',
          userSettings(
            isAfterChange: false,
          ),
          Icon(
            Icons.settings,
            color: primaryColor,
            size: 50,
          )),
      dashBoardContainers(
          'Support',
          support(),
          Icon(
            Icons.contact_support,
            color: primaryColor,
            size: 50,
          )),
      dashBoardContainers(
          'Favorites',
          favorites(),
          Icon(
            Icons.bookmark,
            color: primaryColor,
            size: 50,
          )),
    ];
    return Scaffold(
        backgroundColor: primaryColor,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: ListView(children: [
              Container(
                height: 1,
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       padding: EdgeInsets.all(5),
              //       height: 50,
              //       width: 100,
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(35),
              //           color: offersColor),
              //       child: Row(
              //         children: [
              //           Icon(
              //             Icons.monetization_on,
              //             color: primaryColor,
              //             size: 30,
              //           ),
              //           Text(
              //             " $userBalance ",
              //             style: new TextStyle(
              //                 fontWeight: FontWeight.bold,
              //                 color: primaryColor,
              //                 fontSize: 30.0),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              Container(
                height: 15,
              ),
              // Expanded(child: Container(width: double.infinity, height: 120,)),
              CarouselSlider(
                options: CarouselOptions(height: 160.0, autoPlay: true),
                items: [
                  'https://images.unsplash.com/photo-1654805202479-317617a76e2d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwyfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60',
                  'https://images.unsplash.com/photo-1648737154448-ccf0cafae1c2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80',
                  'https://images.unsplash.com/photo-1654851665266-c6c573737f52?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw0fHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60',
                ].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                          clipBehavior: Clip.hardEdge,
                          width: kIsWeb
                              ? MediaQuery.of(context).size.width * 0.5
                              : MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                              clipBehavior: Clip.hardEdge,
                              child: Image.network(
                                i,
                                // fit: BoxFit.contain,
                                fit: BoxFit.cover,
                              )));
                    },
                  );
                }).toList(),
              ),

              Container(
                height: 20,
              ),
              //chat and myOffers
              //here
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        dashboardContainer(x[0].label, x[0].icon, x[0].widget),
                        Container(
                          width: 20,
                        ),
                        dashboardContainer(x[1].label, x[1].icon, x[1].widget),
                      ],
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        dashboardContainer(x[2].label, x[2].icon, x[2].widget),
                        Container(
                          width: 20,
                        ),
                        dashboardContainer(x[3].label, x[3].icon, x[3].widget),
                      ],
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        dashboardContainer(x[4].label, x[4].icon, x[4].widget),
                        Container(
                          width: 20,
                        ),
                        dashboardContainer(x[5].label, x[5].icon, x[5].widget),
                      ],
                    ),
                  ),
                ],
              )
            ]),
          ),
        ));
  }

  Widget dashboardContainer(String label, Icon icon, Widget widget) {
    return InkWell(
      onTap: () {
        navigateTo(context, widget);
      },
      child: Container(
        margin: EdgeInsets.only(top: 30, bottom: 5, right: 5, left: 5),
        padding: EdgeInsets.all(5),
        width: kIsWeb
            ? MediaQuery.of(context).size.width * 0.18
            : MediaQuery.of(context).size.width * 0.35,
        height: kIsWeb
            ? MediaQuery.of(context).size.width * 0.11
            : MediaQuery.of(context).size.width * 0.22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: offersColor,
        ),
        child: FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(fontSize: 50, color: primaryColor)),
              icon
            ],
          ),
        ),
      ),
    );
  }
}

class dashBoardContainers {
  String label;
  Icon icon;
  Widget widget;

  dashBoardContainers(this.label, this.widget, this.icon);
}