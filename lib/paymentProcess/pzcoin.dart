import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:zone/paymentProcess/payment5Coins.dart';
import 'package:zone/paymentProcess/paymentController.dart';

import 'package:zone/paymentProcess/paymentModel.dart';
import 'package:zone/screens/main_page.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

import '../additional/colors.dart';
import './PurchaseApi.dart';

class pzcoin extends StatefulWidget {
  const pzcoin({Key? key}) : super(key: key);

  @override
  State<pzcoin> createState() => _pzcoinState();
}

class _pzcoinState extends State<pzcoin> {
  final List<String> _productLists = [
    '5coins',
    '10coins',
    '20coins',
    '100coins',
    '200coins',
    '1coins',
  ];

  double userBalance = 0.0;
  var userData = {};

  @override
  initState() {
    super.initState();
    getData();
  }

  getData() async {
    var snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    userData = snap.data()!;
    userBalance = double.parse(userData['balance']);
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<PaymentTile> coinOffers = [
    PaymentTile("The Zoin Coin", "5", '5', '5coins', false),
    PaymentTile("The Zoin Coin", "10", '10', '10coins', false),
    PaymentTile("The Zoin Coin", "20", '20', '20coins', false),
    PaymentTile("The Zoin Coin", "100", '100', '100coins', false),
    PaymentTile("The Zoin Coin", "200", '200', '200coins', true),
  ];

  Set<String> offersIDs = {
    '5coins',
    '10coins',
    '20coins',
    '100coins',
    '200coins',
  };
  Map<String, dynamic>? paymentIntentData;

  Future<void> initPayment(
      {required String email,
      required double amount,
      required BuildContext context}) async {
    try {
      // 1. Create a payment intent on the server
      final response = await http.post(
          Uri.parse(
              'https://us-central1-zone-b3608.cloudfunctions.net/stripePaymentIntentRequest'),
          body: {
            'email': email,
            'amount': amount.toString(),
          });

      final jsonResponse = json.decode(response.body);
      log(jsonResponse.toString());
      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: jsonResponse['paymentIntent'],
        merchantDisplayName: 'The Zoin Coins',
        customerId: jsonResponse['customer'],
        customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
        testEnv: false,
        merchantCountryCode: 'US',
      ));
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: offersColor,
              ),
            ],
          ),
        ),
      );
      setState(() {
        userBalance += (amount / 100);
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'balance': userBalance});
      navigateTo(context, mainPage(isFromSettings: false));
    } catch (errorr) {
      if (errorr is StripeException) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('An error occured(Stripe Exception) ${errorr.error.localizedMessage}'),
        //   ),
        //
        // );
        print(errorr.error.localizedMessage);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured(else) $errorr'),
          ),
        );
        print(errorr);
      }
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
      body: ListView.builder(
        controller: ScrollController(),
        itemBuilder: (BuildContext context, index) {
          return coinOffers.length == 0
              ? Center(
                  child: Text('There is no offers at the moment'),
                )
              : paymentTiles(
                  context,
                  coinOffers[index].label,
                  coinOffers[index].offeredPrice,
                  coinOffers[index].coins,
                  coinOffers[index].IAPID,
                  coinOffers[index].bestOffer,
                  index);
        },
        shrinkWrap: true,
        itemCount: coinOffers.length,
      ),
    );
  }

  Widget paymentTiles(BuildContext context, label, String offeredPrice,
      String coins, String IAPID, bool bestOffer, index) {
    return Stack(children: [
      GestureDetector(
        onTap: () {},
        child: Container(
          margin: EdgeInsets.only(bottom: 10, top: 10, right: 20, left: 20),
          decoration: BoxDecoration(
              color: Colors.green.shade200,
              borderRadius: BorderRadius.circular(30)),
          child: ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: offersColor,
                    ),
                    Text(
                      coins,
                      style: TextStyle(
                        color: offersColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(30)),
              ),
              title: Container(
                margin: EdgeInsets.only(bottom: 15, top: 15, right: 25),
                decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(30)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 30,
                    ),
                    Center(
                      child: Text(
                        '\$${offeredPrice}',
                        style: TextStyle(color: offersColor, fontSize: 24),
                      ),
                    ),
                    FittedBox(
                      child: Container(
                        padding: EdgeInsets.all(7),
                        child: FittedBox(
                          child: Row(
                            children: [
                              FittedBox(
                                child: Text(
                                  'Buy',
                                  style: TextStyle(
                                      color: primaryColor, fontSize: 20),
                                ),
                              ),
                              FittedBox(
                                child: Icon(
                                  Icons.shopping_cart,
                                  color: primaryColor,
                                ),
                              )
                            ],
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: offersColor,
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    )
                  ],
                ),
              ),
              onTap: () async {
                await initPayment(
                    email: FirebaseAuth.instance.currentUser!.email.toString(),
                    amount: double.parse(offeredPrice) * 100,
                    context: context);
              }),
        ),
      ),
      bestOffer == true
          ? Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.4),
              child: Text(
                'Best Offer %',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                  foreground: Paint()
                    ..style = PaintingStyle.fill
                    ..strokeWidth = 3
                    ..color = Colors.red,
                ),
              ),
            )
          : SizedBox.shrink()
    ]);
  }
}
