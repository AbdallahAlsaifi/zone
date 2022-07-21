import 'dart:async';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:zone/screens/mainPages/addOfferMain/mainOfferCard.dart';
import 'package:zone/screens/mainPages/homeScreen/userSearchCard.dart';
import 'package:zone/screens/mainPages/offerProfile.dart';
import 'package:zone/screens/mainPages/profileScreen.dart';
import '../../../../widgets/AdditionalWidgets.dart';
import 'homeOfferCard.dart';
enum Menu { itemOne, itemTwo, itemThree, itemFour }

class homeScreen extends StatefulWidget {
  const homeScreen({Key? key}) : super(key: key);

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  TextEditingController searchControlling = new TextEditingController();
  bool isShowing = false;
  String searchKey = '';
  int searchChoice = 0;
  bool isThereAnOffers = true;
  int numberOfTags = 7;
  List y = [];
  List z = [];

  int random(min, max) {
    return min + Random().nextInt(max - min);
  }

  void randomTags() async {
    List x = [];

    final QuerySnapshot qSnap =
        await FirebaseFirestore.instance.collection('Category').get();
    final int documents = qSnap.docs.length;

    if (documents > 0) {
      for (int i = 0; i <= 6; i++) {
        int d = random(0, documents);
        List snap2 = qSnap.docs[d].get('categoryTags');
        x.add(snap2.elementAt(random(0, snap2.length)).toString());
      }
      print(x);
      setState(() {
        y = x;
      });
    }
  }

  @override
  Widget topViews(tag, duration) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHight = MediaQuery.of(context).size.height;
    Stream<QuerySnapshot<Map<String, dynamic>>> db = FirebaseFirestore.instance
        .collection('Category')
        .where('categoryTags', arrayContains: tag)
        .snapshots();

    return StreamBuilder(
      stream: db,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 1,
          itemBuilder: (context, index) {
            return Container(
              child: Column(
                children: [
                  Container(
                    width: screenWidth * 0.39,
                    padding: EdgeInsets.all(8),
                    child: FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '#$tag'.toString().toUpperCase(),
                            style: TextStyle(color: offersColor),
                          )
                        ],
                      ),
                    ),
                  ),
                  CarouselSlider(
                    items: List<Widget>.generate(snapshot.data!.docs.length,
                        (index) {
                      return Container(
                        margin: EdgeInsets.all(8),
                        child: HomeOfferCard(
                          isSearch: false,
                          snap2: snapshot.data!.docs[index],
                          snap: snapshot.data!.docs[index],
                          isLocal: false,
                          OfferId: snapshot.data!.docs[index]['offerId'],
                          OwnerId: snapshot.data!.docs[index]['uid'],
                        ),
                      );
                    }),
                    options: CarouselOptions(
                        height: 150.0,
                        autoPlay: true,
                        autoPlayAnimationDuration: Duration(seconds: duration)),
                  ),
                  Divider(
                    thickness: 2,
                    height: 1,
                  )
                ],
              ),
            );
          },
        );

        // return Center(child: Text('${snapshot.data!.docs[0]['title']}'),);
      },
    );
  }

  String _selectedMenu = '';

  @override
  void initState() {
    randomTags();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: offersColor,
          onPressed: () => null,
        ),
        backgroundColor: offersColor,
        flexibleSpace: SafeArea(
          child: Container(
            color: offersColor, // set your color
            child: FittedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 3,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Expanded(
                              child: Form(
                                child: TextFormField(
                                  controller: searchControlling,
                                  onChanged: (value) {
                                    setState(() {
                                      isShowing = true;
                                    });
                                    if (searchControlling.text.isEmpty) {
                                      setState(() {
                                        isShowing = false;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration.collapsed(
                                      hintText: 'Search'),
                                  onFieldSubmitted: (String _) {
                                    setState(() {
                                      isShowing = true;
                                      searchKey = searchControlling
                                          .text.characters.first
                                          .toString()
                                          .toLowerCase();
                                    });
                                    print(_);
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    isShowing = false;
                                    searchControlling.text = "";
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 2,
                  ) // set an icon or image
                  // set your search bar setting
                ],
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<Menu>(
              icon: Icon(
                Icons.filter_alt,
                color: primaryColor,
              ),
              // Callback that sets the selected popup menu item.
              onSelected: (Menu item) {
                setState(() {
                  _selectedMenu = item.name;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                PopupMenuItem<Menu>(
                  value: Menu.itemOne,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Top Sales'),
                      Icon(
                        Icons.monetization_on_outlined,
                        color: Colors.amber,
                      )
                    ],
                  ),
                ),
                PopupMenuItem<Menu>(
                  value: Menu.itemTwo,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Top Rated'),
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                      )
                    ],
                  ),
                ),
                PopupMenuItem<Menu>(
                  value: Menu.itemThree,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('New Offers'),
                      Icon(
                        Icons.timer_sharp,
                        color: Colors.grey,
                      )
                    ],
                  ),
                ),
                PopupMenuItem<Menu>(
                  value: Menu.itemFour,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Old Offers'),
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.grey,
                      )
                    ],
                  ),
                ),
              ])
        ],
      ),
      body: isShowing
          ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          searchChoice = 0;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(4),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(color: offersColor),
                            borderRadius: BorderRadius.circular(15),
                            color:
                                searchChoice == 0 ? offersColor : primaryColor),
                        child: Text(
                          'Offers',
                          style: TextStyle(
                              fontSize: 21,
                              color: searchChoice == 0
                                  ? primaryColor
                                  : offersColor),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          searchChoice = 1;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(4),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(color: offersColor),
                            borderRadius: BorderRadius.circular(15),
                            color:
                                searchChoice == 1 ? offersColor : primaryColor),
                        child: Text(
                          'Users',
                          style: TextStyle(
                              fontSize: 21,
                              color: searchChoice == 1
                                  ? primaryColor
                                  : offersColor),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 3,
                  child: searchChoice == 0
                      ? FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('Category')
                              .where('searchKeys',
                                  arrayContains:
                                      searchControlling.text.toString().trim())
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: offersColor,
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount:
                                  (snapshot.data! as dynamic).docs!.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return offerProfile(
                                        uid: (snapshot.data! as dynamic)
                                            .docs[index]['offerId'],
                                        ownerUid: (snapshot.data! as dynamic)
                                            .docs[index]['uid'],
                                      );
                                    }),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      HomeOfferCard(
                                        isSearch: true,
                                        isLocal: false,
                                        snap2: (snapshot.data! as dynamic)
                                            .docs[index],
                                        OwnerId: (snapshot.data! as dynamic)
                                            .docs[index]['uid'],
                                        OfferId: (snapshot.data! as dynamic)
                                            .docs[index]['offerId'],
                                        snap: (snapshot.data! as dynamic)
                                            .docs[index],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .where('fname',
                                  isGreaterThanOrEqualTo:
                                      searchControlling.text.toString().trim())
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: offersColor,
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount:
                                  (snapshot.data! as dynamic).docs!.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) {
                                      return profileScreen(
                                        uid: (snapshot.data! as dynamic)
                                            .docs[index]['uid'],
                                        isVisiting: true,
                                      );
                                    }),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      userSearchCard(
                                        isSearch: true,
                                        snap2: (snapshot.data! as dynamic)
                                            .docs[index],
                                        snap: (snapshot.data! as dynamic)
                                            .docs[index],
                                        OwnerId: (snapshot.data! as dynamic)
                                            .docs[index]['uid'],
                                        isLocal: false,
                                        OfferId: (snapshot.data! as dynamic)
                                            .docs[index]['uid'],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            )
          : ListView(
              children: [
                topViews('${y[0].toString().toLowerCase()}', 1),
                topViews('${y[1].toString().toLowerCase()}', 2),
                topViews('${y[2].toString().toLowerCase()}', 3),
                topViews('${y[3].toString().toLowerCase()}', 4),
                topViews('${y[4].toString().toLowerCase()}', 5),
                topViews('${y[5].toString().toLowerCase()}', 6),
                topViews('${y[6].toString().toLowerCase()}', 7),
              ],
            ),
      backgroundColor: primaryColor,
    );
  }
}
