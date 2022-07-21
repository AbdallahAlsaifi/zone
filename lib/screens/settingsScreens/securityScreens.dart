import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../additional/colors.dart';
import '../../widgets/AdditionalWidgets.dart';
import '../../widgets/text_field_input.dart';
import '../auth/fire_auth.dart';

class securityScreens extends StatefulWidget {
  const securityScreens({Key? key}) : super(key: key);

  @override
  State<securityScreens> createState() => _securityScreensState();
}

class _securityScreensState extends State<securityScreens> {
  @override
  String password = "";
  bool _isLoading = false;
  String res = "";

  final TextEditingController _passwordController = TextEditingController();

  void initState() {
    // TODO: implement initState
    super.initState();
    getUserPassword();

  }
  getUserPassword() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      password = (snap.data() as Map<String, dynamic>)['password'];
    });
  }
  updateuserPassword() async {
    setState(() {
      _isLoading = true;
    });

    String result = await FireAuth()
        .updatePassword(newCred: _passwordController.text.trim());

    try {
      if (result != 'success') {
        falseSnackBar(context, result, widget);
        showAlertDialog(
            context,
            "Error!",
            result,
            Icon(
              Icons.error,
              color: Colors.red,
            ));
      } else {
        setState(() {
          res = "success";
        });
        showAlertDialog(
            context,
            "",
            "Success",
            Icon(
              Icons.check,
              color: Colors.green,
            ));
        navigatePop(context, widget);
        trueSnackBar(context, widget);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e.toString());
      falseSnackBar(context, e.toString(), widget);
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: secColor,
        ),
        title: Text(
          'Security',
          style: TextStyle(color: secColor),
        ),
        elevation: 0,
        backgroundColor: primaryColor,
      ),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  settingButton2(
                      "Password:",
                      "******",
                      context,
                      passwordSettingDialog(
                        context,
                    widget,
                    _passwordController,
                    "Password",
                    "******",
                    _isLoading,
                  )),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
  Dialog passwordSettingDialog(context,
      widget,
      TextEditingController skill1,
      String label,
      String hintText,
      bool IsLoading,) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      //this right here
      child: Padding(
        child: Container(
          height: 300.0,
          width: 300.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                label,
                style: TextStyle(color: secColor),
              ),
              TextFieldInput(
                  textEditingController: skill1,
                  isPass: true,
                  hintText: hintText,
                  textInputType: TextInputType.visiblePassword),

              SizedBox(
                height: 10,
              ),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        navigatePop(context, widget);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.green, fontSize: 18.0),
                      )),
                  TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.currentUser!
                            .updatePassword(_passwordController.text.trim());
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update(
                                {'password': _passwordController.text.trim()});
                        updateuserPassword();
                        navigatePop(context, widget);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    super.widget));
                      },
                      child: Text(
                        'Change',
                        style: TextStyle(color: Colors.green, fontSize: 18.0),
                      ))
                ],
              )
            ],
          ),
        ),
        padding: EdgeInsets.all(20),
      ),
    );
  }
}
