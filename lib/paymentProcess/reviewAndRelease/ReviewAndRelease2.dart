import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/mainPages/InDashBoard/dashboard.dart';
import 'package:zone/screens/main_page.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

class ReviewAndRelease2 extends StatefulWidget {
  final offerRating;
  final offerComment;
  final contractId;

  const ReviewAndRelease2(
      {Key? key,
      required this.offerComment,
      required this.offerRating,
      required this.contractId})
      : super(key: key);

  @override
  State<ReviewAndRelease2> createState() => _ReviewAndRelease2State();
}

class _ReviewAndRelease2State extends State<ReviewAndRelease2> {
  TextEditingController _usercommentController = new TextEditingController();
  var userData = {};
  var sellerData = {};
  var contractData = {};
  var offerData = {};
  String startingTime = " ";
  List userActiveContracts = [];
  List sellerActiveContracts = [];
  List userCompletedContracts = [];
  List sellerCompletedContracts = [];
  bool isLoading = false;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  double offerPrice = 0.0;

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  double sellerBalance = 0.0;

  getData() async {
    try {
      var snap = await FirebaseFirestore.instance
          .collection('Contracts')
          .doc(widget.contractId)
          .get();
      contractData = snap.data()!;
      var snap2 = await FirebaseFirestore.instance
          .collection('users')
          .doc(contractData['buyerId'])
          .get();
      userData = snap2.data()!;
      var snap3 = await FirebaseFirestore.instance
          .collection('users')
          .doc(contractData['sellerId'])
          .get();
      sellerData = snap3.data()!;
      var snap4 = await FirebaseFirestore.instance
          .collection('Category')
          .doc(contractData['offerId'])
          .get();
      offerData = snap4.data()!;
      setState(() {
        sellerBalance = sellerData['balance'];
        offerPrice = double.parse(offerData['price']);
        startingTime = contractData['startingDate'];
        userActiveContracts = userData['activeContracts'];
        sellerActiveContracts = sellerData['activeContracts'];
        userCompletedContracts = userData['completedContracts'];
        sellerCompletedContracts = sellerData['completedContracts'];
      });
    } catch (e) {}
  }

  double _ratingHolder = 0;

  Future<void> submitRatingAndCloseContract() async {
    try {
      setState(() {
        isLoading = true;
      });
      String randomId = Uuid().v1();
      await firebaseFirestore
          .collection('Category')
          .doc(contractData['offerId'])
          .collection('comments')
          .doc(randomId)
          .set({
        'comment': widget.offerComment,
        'ratedBy': userData['uid'],
        'rate': widget.offerRating,
        'fname': userData['fname'],
        'lname': userData['name'],
        'profilePhotoUrl': userData['profilePhotoUrl']
      });
      await firebaseFirestore
          .collection('users')
          .doc(contractData['sellerId'])
          .collection('comments')
          .doc(randomId)
          .set({
        'comment': _usercommentController.text,
        'ratedBy': userData['uid'],
        'rate': _ratingHolder,
        'fname': userData['fname'],
        'lname': userData['name'],
        'profilePhotoUrl': userData['profilePhotoUrl']
      });

      updateDataFirestore('Contracts', contractData['contractId'], {
        'endingDate': DateTime.now().toString(),
        'totalTime':
            DateTime.now().difference(DateTime.parse(startingTime)).toString(),
      });

      setState(() {
        sellerActiveContracts.remove(widget.contractId);
        userActiveContracts.remove(widget.contractId);
        sellerCompletedContracts.add(widget.contractId);
        userCompletedContracts.add(widget.contractId);

        isLoading = false;
      });
      await firebaseFirestore
          .collection('users')
          .doc(contractData['sellerId'])
          .update({
        'activeContracts': sellerActiveContracts,
        'completedContracts': sellerCompletedContracts,
      });
      await firebaseFirestore
          .collection('users')
          .doc(contractData['buyerId'])
          .update({
        'activeContracts': sellerActiveContracts,
        'completedContracts': sellerCompletedContracts,
      });
    } catch (e) {}
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: offersColor,
        title: Text(
          'Ending contract',
          style: TextStyle(color: primaryColor),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(8),
          children: [
            Container(
              height: 30,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                    'How do you rate your satisfaction\nabout ${sellerData['fname']}?',
                    style: TextStyle(color: offersColor, fontSize: 18)),
                Container(
                  height: 30,
                ),
                RatingBar.builder(
                  itemSize: MediaQuery.of(context).size.width * 0.1,
                  ignoreGestures: false,
                  glow: true,
                  initialRating: 0,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _ratingHolder = rating;
                    });
                  },
                ),
              ],
            ),
            Divider(
              thickness: 2,
              height: 100,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text('Any comment on ${sellerData['fname']}?',
                    style: TextStyle(color: offersColor, fontSize: 18)),
                Container(
                  height: 30,
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(15),
              child: TextField(
                  controller: _usercommentController,
                  cursorColor: offersColor,
                  maxLines: 20,
                  minLines: 5,
                  maxLength: 300,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: offersColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                  )),
            ),
            InkWell(
              onTap: () async {
                if (_ratingHolder > 0) {
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    setState(() {
                      sellerBalance += offerPrice;
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(sellerData['uid'])
                        .update({'balance': sellerBalance});

                    await submitRatingAndCloseContract();
                    navigateTo(context, mainPage(isFromSettings: false));
                    Fluttertoast.showToast(msg: 'Contract Closed');
                    setState(() {
                      isLoading = false;
                    });
                  } catch (e) {}
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(""),
                        content: Text(
                            "Please make sure of that You rated the offer"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                //here
                                navigatePop(context, widget);
                              },
                              child: Text(
                                "Ok",
                                style: TextStyle(color: offersColor),
                              )),
                        ],
                      );
                    },
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: offersColor,
                        borderRadius: BorderRadius.circular(35)),
                    margin: EdgeInsets.only(top: 20),
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: primaryColor,
                          )
                        : Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Release',
                                    style: TextStyle(
                                        color: primaryColor, fontSize: 24)),
                                Icon(
                                  Icons.monetization_on_outlined,
                                  color: primaryColor,
                                )
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
