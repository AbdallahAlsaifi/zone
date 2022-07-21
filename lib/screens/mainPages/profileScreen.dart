import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/SeeUserOffers.dart';
import 'package:zone/screens/auth/fire_auth.dart';
import 'package:zone/screens/auth/login.dart';
import 'package:zone/screens/mainPages/addOfferMain/mainOfferCard.dart';
import 'package:zone/screens/mainPages/usercommentsScreen.dart';
import 'package:zone/screens/settingsScreens/Portfolio/MainPortfolioCard.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

import '../settingsScreens/userSettings.dart';

class profileScreen extends StatefulWidget {
  final String uid;
  final bool isVisiting;

  const profileScreen({Key? key, required this.uid, required this.isVisiting})
      : super(key: key);

  @override
  State<profileScreen> createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  @override
  String username = "";
  bool isZoner = true;
  bool isPro = false;
  bool isGold = false;
  bool isStar = false;
  bool isVerified = false;
  String rank = "";
  String userRating = "0";
  String userId = "";
  List skills = [];
  int portLen = 0;

  var sss;

  @override
  void initState() {
    super.initState();
    getData();

    // getData();
  }

  var userData = {};
  var comments = {};
  int commentsLength = 0;
  double totalRate = 0;
  double rate = 0;

  getData() async {
    var snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
    var portSnap = await FirebaseFirestore.instance
        .collection('Portfolio')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    var snap3 = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('comments')
        .get();
    portLen = portSnap.docs.length;
    userData = snap.data()!;
    setState(() {
      username = userData['username'];
      rank = userData['rank'];
      userRating = userData['rating'];
      userId = userData['uid'];
      skills = userData['skills'];
      commentsLength = snap3.docs.length;
      snap3.docs.forEach((value) {
        var rate = value.data()!['rate'];
        totalRate = totalRate + rate;
      });
      rate = totalRate / commentsLength;
      print(rate);
    });
    checkRank();
  }

  checkRank() {
    if (rank.toLowerCase() == 'zoner') {
      isZoner = true;
      return badge("welcome.svg", 90, 90, isZoner);
    } else if (rank.toLowerCase() == 'pro') {
      isZoner = true;
      isPro = true;
      return badge('pro.svg', 90, 90, isPro);
    } else if (rank.toLowerCase() == 'gold') {
      isZoner = true;
      isPro = true;
      isGold = true;
      return badge('gold.svg', 90, 90, isGold);
    } else if (rank.toLowerCase() == 'star') {
      isZoner = true;
      isPro = true;
      isGold = true;
      isStar = true;
      return badge('star.svg', 90, 90, isStar);
    }
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 60.0;
    return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          leading: widget.isVisiting
              ? IconButton(
                  icon: Icon(
                    Icons.adaptive.arrow_back,
                    color: offersColor,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : null,
          elevation: 0,
          backgroundColor: primaryColor,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.isVisiting
                ? null
                : GestureDetector(
                    onTap: () {
                      navigateTo(
                          context,
                          const userSettings(
                            isAfterChange: false,
                          ));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Edit',
                          style: TextStyle(color: offersColor),
                        ),
                        Icon(
                          Icons.settings,
                          color: secColor,
                        ),
                      ],
                    ),
                  ),
          ),
          centerTitle: true,
        ),
        body: Center(
            child: checker(
          username,
          ListView(
            physics: PageScrollPhysics(),
            padding: EdgeInsets.all(20),
            children: [
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 350,
                          width: width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 5,
                                height: 120,
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    border: Border.all(color: primaryColor)),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          '${userData['fname']} ${userData['lname']}',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: offersColor),
                                        ),
                                        Text(
                                          ' @${userData['username']}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: offersColor),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            navigateTo(
                                                context,
                                                userComments(
                                                    userId: widget.uid));
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              FittedBox(
                                                child: rating(
                                                    rate.isNaN
                                                        ? 0
                                                        : double.parse(rate
                                                            .toStringAsFixed(
                                                                1)),
                                                    true,
                                                    19),
                                              ),
                                              Text(
                                                '(${commentsLength})',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    ),
                                  ],
                                ),
                                height: 80,
                                decoration: BoxDecoration(
                                    color: primaryColor,
                                    border: Border.all(color: primaryColor)),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 8,
                                            bottom: 8,
                                            top: 15,
                                            right: 8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 75,
                                              child: FittedBox(
                                                child: Text(
                                                  "Sold Offers",
                                                  style: new TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: primaryColor,
                                                      letterSpacing: 1),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 5,
                                            ),
                                            CircularPercentIndicator(
                                              circularStrokeCap:
                                                  CircularStrokeCap.butt,
                                              backgroundColor:
                                                  oldRankPercentColor() ??
                                                      offersColor,
                                              progressColor: rankPercentColor(),
                                              radius: 36.0,
                                              animation: true,
                                              animationDuration: 2000,
                                              lineWidth: 6.0,
                                              percent: 55 / 100,
                                              center: Text(
                                                "${userData['soldOffers']}",
                                                style: new TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryColor,
                                                    fontSize: 15.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 5,
                                    height: 150,
                                    decoration: BoxDecoration(
                                        color: primaryColor,
                                        border:
                                            Border.all(color: primaryColor)),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 8,
                                            bottom: 8,
                                            top: 15,
                                            right: 8),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      child: FittedBox(
                                                        child: Text(
                                                          "Rank",
                                                          style: new TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  primaryColor,
                                                              letterSpacing: 1,
                                                              fontSize: 18.0),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 5,
                                                    ),
                                                    CircularPercentIndicator(
                                                      circularStrokeCap:
                                                          CircularStrokeCap
                                                              .butt,
                                                      backgroundColor:
                                                          oldRankPercentColor(),
                                                      progressColor:
                                                          rankPercentColor(),
                                                      radius: 36.0,
                                                      animation: true,
                                                      animationDuration: 2000,
                                                      lineWidth: 6.0,
                                                      percent: 100 / 100,
                                                      center: Text(
                                                        rank.toUpperCase(),
                                                        style: new TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: primaryColor,
                                                            fontSize: 15.0),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40.0),
                                topLeft: Radius.circular(40.0),
                                bottomRight: Radius.circular(40.0),
                                bottomLeft: Radius.circular(40.0)),
                            color: secColor,
                          ),
                        ),
                        Positioned(
                          bottom: 280,
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: primaryColor,
                            child: CircleAvatar(
                              backgroundColor: primaryColor,
                              backgroundImage:
                                  NetworkImage(userData['profilePhotoUrl']),
                              radius: 50,
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 290,
                            left: MediaQuery.of(context).size.width * 0.61,
                            child: checkRank()),
                        Positioned(
                            bottom: 290,
                            right: MediaQuery.of(context).size.width * 0.61,
                            child: badge("verified.svg", 90, 90, false)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 7.0,
              ),
              Divider(thickness: 2),
              SizedBox(
                height: 7.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Badges",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        color: offersColor,
                        fontSize: 20.0),
                  ),
                  GestureDetector(
                    onTap: () {
                      navigateTo(context, seeUserOffers(uid: userId));
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'See user offers',
                            style: TextStyle(color: primaryColor),
                          ),
                          Icon(
                            Icons.local_offer_sharp,
                            color: primaryColor,
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: offersColor,
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
              Container(
                height: 5,
              ),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: secColor),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            badge("welcome.svg", 60, 60, isZoner),
                            badge("verified.svg", 60, 60, isVerified),
                            badge("pro.svg", 60, 60, isPro),
                            badge("gold.svg", 60, 60, isGold),
                            badge("star.svg", 60, 60, isStar),
                          ])
                    ],
                  )),
              SizedBox(
                height: 7.0,
              ),
              Divider(thickness: 2),
              SizedBox(
                height: 10.0,
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Skills",
                    style: TextStyle(
                        letterSpacing: 1,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: secColor),
                  ),
                  Icon(
                    Icons.school,
                    color: offersColor,
                    size: 22,
                  )
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  children: [
                    for (var i in skills!)
                      (Chip(
                        labelStyle: TextStyle(color: primaryColor),
                        label: Text(i.toString()),
                        backgroundColor: offersColor,
                      ))
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Divider(
                thickness: 2,
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        "About me",
                        style: TextStyle(
                            color: secColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 1,
                      ),
                      Icon(
                        Icons.boy_sharp,
                        color: offersColor,
                        size: 25,
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Wrap(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: offersColor, width: 1)),
                            child: Text(
                              userData['bio'],
                              style: TextStyle(
                                color: secColor.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Divider(
                thickness: 2,
              ),
              SizedBox(
                height: 15,
              ),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "Portfolio",
                  style: TextStyle(
                      color: Colors.teal,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                SizedBox(
                  height: 20,
                ),
              ]),
              Container(
                height: 10,
              ),
              FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('Portfolio')
                    .where('uid', isEqualTo: widget.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Container(
                    height:
                        ((snapshot.data! as dynamic).docs.length * 330) * 0.8,
                    child: GridView.builder(
                      physics: PageScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 180,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                            (snapshot.data! as dynamic).docs[index];

                        return Container(
                            child: MainPortfolioCard(
                          snap: snap,
                          isLocal: false,
                        ));
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        )));
  }

  rankPercentColor() {
    if (rank.toLowerCase() == 'zoner') {
      return Colors.grey;
    } else if (rank.toLowerCase() == 'pro') {
      return Colors.blue;
    } else if (rank.toLowerCase() == 'gold') {
      return Colors.amber;
    } else if (rank.toLowerCase() == 'star') {
      return offersColor;
    }
  }

  oldRankPercentColor() {
    Color x = offersColor;
    if (rank.toLowerCase() == 'zoner') {
      x = Colors.grey;
    } else if (rank.toLowerCase() == 'pro') {
      x = Colors.white;
    } else if (rank.toLowerCase() == 'gold') {
      x = Colors.amber;
    } else if (rank.toLowerCase() == 'star') {
      x = offersColor;
    } else if (rank.isNull) {
      x = offersColor;
    }
    return x;
  }
}
