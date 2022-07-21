import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/main_page.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

class support extends StatefulWidget {
  const support({Key? key}) : super(key: key);

  @override
  State<support> createState() => _supportState();
}

class _supportState extends State<support> {
  TextEditingController fieldText = new TextEditingController();
  bool _isLoading = false;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: FittedBox(
                        child: Text(
                          'Request a support',
                          style: TextStyle(color: offersColor),
                        ))),
              ],
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: TextField(
                  onChanged: (value) {
                    setState(() {
                      fieldText.text = value;
                    });
                  },
                  cursorColor: offersColor,
                  maxLines: 500,
                  minLines: 5,
                  maxLength: 5000,
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
            Row(
              children: [
                Expanded(child: Container()),
                GestureDetector(
                  onTap: () async {
                    if (fieldText.text.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Can't send an empty request!!");
                    } else {
                      try {
                        setState(() {
                          _isLoading = true;
                        });

                        await FirebaseFirestore.instance
                            .collection('Support')
                            .doc(DateTime.now().toString())
                            .collection(DateTime.now().toString())
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .set({
                          'status': 'Pending Review',
                          'Request': fieldText.text
                        });

                        setState(() {
                          _isLoading = false;
                        });
                        Fluttertoast.showToast(
                            msg:
                                "Sent Successfully:\nyou will receive a reply email soon\nplease make sure your email is updated");
                        navigateTo(context, mainPage(isFromSettings: false));
                      } catch (e) {
                        Fluttertoast.showToast(msg: "Error: Please try again");
                      }
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    padding: EdgeInsets.all(10),
                    child: FittedBox(
                        child: _isLoading
                            ? CircularProgressIndicator(
                                color: primaryColor,
                              )
                            : Text(
                                'Send',
                                style: TextStyle(color: primaryColor),
                              )),
                    decoration: BoxDecoration(
                        color: offersColor,
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
            Divider(
              thickness: 1,
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: FittedBox(
                        child: Text(
                          'Or contact us on email\n [support@appers.org]',
                      style: TextStyle(color: offersColor),
                    ))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
