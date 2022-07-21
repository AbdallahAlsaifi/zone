import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zone/screens/mainPages/offerProfile.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

import '../../../additional/colors.dart';

class MainOfferCard extends StatefulWidget {
  final snap;
  final bool isLocal;
  final snap2;

  MainOfferCard(
      {Key? key,
      required this.snap,
      required this.isLocal,
      required this.snap2})
      : super(key: key);

  @override
  _MainOfferCard createState() => _MainOfferCard();
}

class _MainOfferCard extends State<MainOfferCard> {
  bool isFavorite = false;
  var snap55 = {};
  List favOffers = [];
  String rrating = '0';
  int commentsLength = 0;
  double totalRate = 0;
  double rate = 0;
  int usercommentsLength = 0;
  double usertotalRate = 0;
  double userrate = 0;
  var offerData = {};
  var userData = {};
  var CurrentUserData = {};
  var snap3 = {};

  void getData() async {
    try {
      var snapx = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      snap55 = snapx.data()!;
      favOffers = snap55['favoriteOffers'];
      if (favOffers.contains(widget.snap['offerId'])) {
        setState(() {
          isFavorite = true;
        });
      }
      var snap = await FirebaseFirestore.instance
          .collection('Category')
          .doc(widget.snap['offerId'])
          .get();
      var snap2 = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      var snap5 = await FirebaseFirestore.instance
          .collection('Category')
          .doc(widget.snap['offerId'])
          .collection('comments')
          .get();
      offerData = snap.data()!;
      var snap4 = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.snap['uid'])
          .collection('comments')
          .get();

      var snap6 = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.snap['uid'])
          .get();
      userData = snap6.data()!;
      var snapxx = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      snap3 = snapxx.data()!;
      setState(() {
        favOffers = snap3['favoriteOffers'];
        if (favOffers.contains(widget.snap['offerId'])) {
          setState(() {
            isFavorite = true;
          });
        }
      });
      setState(() {
        commentsLength = snap5.docs.length;
        snap5.docs.forEach((value) {
          var rate = value.data()!['rate'];
          totalRate = totalRate + rate;
        });
        usercommentsLength = snap4.docs.length;
        snap4.docs.forEach((value) {
          var rate = value.data()!['rate'];
          usertotalRate = usertotalRate + rate;
        });
        rate = totalRate / commentsLength;
        userrate = usertotalRate / usercommentsLength;

        CurrentUserData = snap2.data()!;

        rrating = userData['rating'];
      });
      print(rate);
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final x = widget.snap['offerId'];
    final y = widget.snap['uid'];
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            navigateTo(
                context,
                offerProfile(
                  uid: x,
                  ownerUid: y,
                ));
          },
          child: Container(
            child: Wrap(spacing: 0, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widget.snap['PhotoUrl'] != null
                      ? Container(
                      child: ClipRect(
                        child: Container(
                          height: 150,
                          width: 100,
                          child: CachedNetworkImage(
                            imageUrl: widget.snap['PhotoUrl'],
                            imageBuilder: (context, imageProvider) =>
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade300,
                              height: 150,
                              width: 100,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image),
                                    Text('image')
                                  ],
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ))
                      : Container(
                    color: Colors.grey.shade300,
                    height: 150,
                    width: 100,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.image), Text('image')],
                      ),
                    ),
                  )
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40)),
                    color: offersColor),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 29,
                        child: Text(
                          'I will ${widget.snap['title']}',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: primaryColor),
                        ),
                      ),
                      Divider(
                        height: 20,
                        thickness: 1,
                        color: primaryColor,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(40),
                                    bottomRight: Radius.circular(40))),
                            child: Text(
                              "${widget.snap['price']} \$",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: offersColor,
                                  fontSize: 25),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              rating(rate.isNaN ? 0 : rate, true, 11.5)
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 10,
              ),
              widget.isLocal
                  ? InkWell(
                onTap: () {},
                child: Container(),
              )
                  : Container(),
              Container(
                height: 10,
              ),
            ]),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: !isFavorite
                  ? InkWell(
                onTap: () {
                  try {
                    print('presses');
                    favOffers!.add(widget.snap['offerId']);
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({'favoriteOffers': favOffers!});
                    Fluttertoast.showToast(msg: 'Added to favorites');
                    setState(() {
                      isFavorite = true;
                    });
                  } catch (e) {
                    Fluttertoast.showToast(msg: 'Please try again later');
                  }
                },
                child: Container(
                  width: 30,
                  child: Icon(
                    CupertinoIcons.heart,
                    color: Colors.red,
                  ),
                ),
              )
                  : InkWell(
                onTap: () {
                  try {
                    print('presses');
                    favOffers!.remove(widget.snap['offerId']);
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({'favoriteOffers': favOffers!});
                    Fluttertoast.showToast(msg: 'Removed from favorites');
                    setState(() {
                      isFavorite = false;
                    });
                  } catch (e) {
                    Fluttertoast.showToast(msg: 'Please try again later');
                  }
                },
                child: Container(
                  width: 30,
                  child: Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
