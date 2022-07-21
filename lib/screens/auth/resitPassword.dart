import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/auth/login1.dart';

import '../../widgets/AdditionalWidgets.dart';

class resitPassword extends StatefulWidget {
  const resitPassword({Key? key}) : super(key: key);

  @override
  State<resitPassword> createState() => _resitPasswordState();
}

class _resitPasswordState extends State<resitPassword> {
  TextEditingController emailfield = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: offersColor,
        title: Text(
          'Password Help',
          style: TextStyle(color: primaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 20),
                    child: TextField(
                      controller: emailfield,
                      cursorColor: offersColor,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: "Your Email",
                        labelStyle: TextStyle(color: offersColor),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: offersColor, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey, width: 2.0),
                        ),
                      ),
                      style: TextStyle(fontSize: 18),
                    ),
                    width: 120,
                    height: 80,
                  ),
                )
              ],
            ),
            Container(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: emailfield.text.trim());
                      Fluttertoast.showToast(
                          msg:
                              'Resit email has been sent\nPlease Check your email');
                      navigateTo(context, login1());
                    } on FirebaseException catch (e) {
                      Fluttertoast.showToast(
                          msg: e.toString().split(']')[1].toString());
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: offersColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        Text(
                          'Send Link',
                          style: TextStyle(fontSize: 23, color: primaryColor),
                        ),
                        Container(
                          width: 7,
                        ),
                        Icon(
                          Icons.email,
                          color: primaryColor,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
