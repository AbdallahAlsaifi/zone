import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zone/Services/dataSearch.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/mainPages/homeScreen/homeOfferCard.dart';
import 'package:zone/screens/mainPages/offerProfile.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

import 'addOfferMain/mainOfferCard.dart';
enum Menu { itemOne, itemTwo, itemThree, itemFour }

class personalOffersScreen extends StatefulWidget {
  const personalOffersScreen({Key? key, bool isUploaded = false})
      : super(key: key);

  @override
  State<personalOffersScreen> createState() => _personalOffersScreenState();
}

class _personalOffersScreenState extends State<personalOffersScreen> {
  void initState() {
    super.initState();

    getData();
  }

  TextEditingController searchControlling = new TextEditingController();
  bool isShowing = false;
  String searchKey = '';
  var snap2 = {};

  void getData() async {
    var snapx = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    snap2 = snapx.data()!;
  }

  String _selectedMenu = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
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
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('Category')
                  .where('searchKeys',
                      arrayContains: searchControlling.text.toString().trim())
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
                  itemCount: (snapshot.data! as dynamic).docs!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return offerProfile(
                            uid: (snapshot.data! as dynamic).docs[index]
                                ['offerId'],
                            ownerUid: (snapshot.data! as dynamic).docs[index]
                                ['uid'],
                          );
                        }),
                      ),
                      child: HomeOfferCard(
                        isSearch: true,
                        isLocal: false,
                        snap2: (snapshot.data! as dynamic).docs[index],
                        OwnerId: (snapshot.data! as dynamic).docs[index]['uid'],
                        OfferId: (snapshot.data! as dynamic).docs[index]
                            ['offerId'],
                        snap: (snapshot.data! as dynamic).docs[index],
                      ),
                    );
                  },
                );
              },
            )
          : SafeArea(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Category')
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Expanded(
                      child: GridView(
                    physics: ScrollPhysics(),
                    padding: EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: kIsWeb ? 4 : 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 210,
                    ),
                    children: List<Widget>.generate(snapshot.data!.docs.length,
                            (index) {
                          return Container(
                              child: MainOfferCard(
                                snap: snapshot.data!.docs[index].data(),
                            isLocal: false,
                            snap2: snap2,
                          ));
                        }) +
                        [
                          Center(
                              child: Wrap(
                            children: [
                              Text(' ', style: TextStyle(fontSize: 14)),
                            ],
                          ))
                        ] +
                        [
                          Container(
                            height: 1,
                          )
                        ],
                  ));
                },
              ),
            ),
    );
  }
}

class SearchService {
  searchByName(String searchField) {
    return FirebaseFirestore.instance
        .collection('Category')
        .where(
          'searchKeys',
          arrayContains: searchField.substring(0, 1).toUpperCase(),
        )
        .get();
  }
}