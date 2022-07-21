import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zone/additional/colors.dart';

class withdraw extends StatefulWidget {
  const withdraw({Key? key}) : super(key: key);

  @override
  State<withdraw> createState() => _withdrawState();
}

class _withdrawState extends State<withdraw> {
  void initState() {
    super.initState();
    getData();
  }

  var userData = {};
  double userWallet = 0.0;
  bool isCandidateToWithdraw = false;

  getData() async {
    try {
      var snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      userData = snap.data()!;
      setState(() {
        userWallet = userData['balance'];
        print(userWallet);
      });
      if (userWallet >= 100) {
        setState(() {
          isCandidateToWithdraw = true;
        });
      }
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Loading ...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SvgPicture.asset(
          'assets/images/zoneLogo.svg',
          color: primaryColor,
          width: 180,
        ),
        backgroundColor: offersColor,
        elevation: 0,
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.all(15),
              child: Center(
                child: FittedBox(
                  child: Text(
                    'Your Current Balance',
                    style: TextStyle(fontSize: 30, color: offersColor),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(15),
              child: FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                    ),
                    Icon(
                      Icons.monetization_on,
                      color: offersColor,
                    ),
                    Text('$userWallet'),
                    Container(
                      width: 30,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (isCandidateToWithdraw) {
                  await FirebaseFirestore.instance
                      .collection('Withdraw')
                      .doc(DateTime.now().toString())
                      .collection(DateTime.now().toString())
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .set({
                    'status': 'Pending Review',
                    'amount': userWallet,
                  });
                  Fluttertoast.showToast(
                      msg:
                          'Your request has been submitted\nsoon you will receive an email to complete the withdraw procedures');
                } else {
                  Fluttertoast.showToast(
                      msg: 'Your balance should be at least 100\$ or more');
                }
              },
              child: Text('Request Withdraw'),
              style: ElevatedButton.styleFrom(primary: offersColor),
            )
          ],
        ),
      ),
    );
  }
}
