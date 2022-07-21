import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/auth/fire_auth.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

import '../../widgets/text_field_input.dart';

class personalSettingsScreen extends StatefulWidget {
  const personalSettingsScreen({Key? key}) : super(key: key);

  @override
  State<personalSettingsScreen> createState() => _personalSettingsScreenState();
}

final TextEditingController _userNameController = TextEditingController();
final TextEditingController _fNameController = TextEditingController();
final TextEditingController _lNameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _phoneNumber = TextEditingController();
final TextEditingController _securityWordController = TextEditingController();

class _personalSettingsScreenState extends State<personalSettingsScreen> {
  String username = "";
  String fname = "";
  String lname = "";
  String phoneNumber = "";
  String email = "";
  String securityWord = "";
  var userData = {};
  bool _isLoading = false;
  String res = "";

  void initState() {
    // TODO: implement initState
    super.initState();

    getUserData();
  }

  updateEmail(newEmail) async {
    await FirebaseAuth.instance.currentUser!
        .updateEmail(newEmail.toString())
        .then((value) {})
        .catchError((error) {
      print(error);
    });
  }

  updateData(oldData, newData) async {
    String result = "";
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(({oldData: newData}));
      result = "success";
      showDialog(
          context: context,
          builder: showAlertDialog(
              context,
              'Success',
              'Your information has been updated successfully',
              Icon(
                Icons.check_circle,
                color: offersColor,
                size: 30,
              )));
    } catch (e) {
      result = e.toString();
    }
    return result;
  }

  getUserData() async {
    var snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    userData = snap.data()!;
    _emailController.text = userData['email'];
    _fNameController.text = userData['fname'];
    _lNameController.text = userData['lname'];
    _userNameController.text = userData['username'];
    _phoneNumber.text = userData['phone'];
    _securityWordController.text = userData['securityWord'];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: secColor,
        ),
        title: Text(
          'Personal Settings',
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
                    "Username:",
                    username,
                    context,
                    usernameSettingDialog(
                      context,
                      widget,
                      _userNameController,
                      "Username:",
                      username,
                      _isLoading,
                    )),
                Divider(),
                settingButton2(
                    "Name:",
                    "   $fname $lname",
                    context,
                    SettingsDialog2(
                        context,
                        widget,
                        _fNameController,
                        _lNameController,
                        "First Name",
                        fname,
                        "Last Name",
                        lname)),
                Divider(),
                settingButton2(
                    "Email:",
                    "   $email",
                    context,
                    emailSettingDialog(
                      context,
                      widget,
                      _emailController,
                      "Email",
                      email,
                      _isLoading,
                    )),
                // Divider(),
                // settingButton2(
                //     "Phone Number:",
                //     phoneNumber,
                //     context,
                //     phoneNumberDialog(context, widget, _phoneNumber,
                //         "Phone Number", phoneNumber, _isLoading)),
              ],
            )),
      ),
    );
  }

  Dialog usernameSettingDialog(
    context,
    widget,
    TextEditingController skill1,
    String label,
    String hintText,
    bool IsLoading,
  ) {
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
                  hintText: hintText,
                  textInputType: TextInputType.text),
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
                      onPressed: () {
                        navigatePop(context, widget);
                        try {
                          updateData('username', _userNameController.text);
                        } catch (e) {
                          print(e.toString());
                        }

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

  Dialog emailSettingDialog(
    context,
    widget,
    TextEditingController skill1,
    String label,
    String hintText,
    bool IsLoading,
  ) {
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
                textEditingController: _emailController,
                hintText: hintText,
                textInputType: TextInputType.emailAddress,
              ),
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
                        navigatePop(context, widget);
                        try {
                          print(_emailController.text);
                          await updateEmail(_emailController.text);
                          await updateData('email', _emailController.text);
                        } catch (e) {
                          print(e.toString());
                        }
                        // Navigator.pushReplacement(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (BuildContext context) =>
                        //             super.widget));
                      },
                      child: Text(
                        'Submit',
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

  Dialog SettingsDialog2(
      context,
      widget,
      TextEditingController skill1,
      TextEditingController skill2,
      String label,
      String hintText,
      String label2,
      String hintText2) {
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
                  hintText: hintText,
                  textInputType: TextInputType.text),
              SizedBox(
                height: 10,
              ),
              Text(
                label2,
                style: TextStyle(color: secColor),
              ),
              TextFieldInput(
                  textEditingController: skill2,
                  hintText: hintText2,
                  textInputType: TextInputType.text),
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
                      onPressed: () {
                        try {
                          updateData('fname', _fNameController.text);
                          updateData('lname', _lNameController.text);
                        } catch (e) {
                          print(e.toString());
                        }
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

  Dialog phoneNumberDialog(
    context,
    widget,
    TextEditingController skill1,
    String label,
    String hintText,
    bool IsLoading,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      //this right here
      child: Padding(
        child: Container(
          height: 300.0,
          width: //get the width of the screen
              MediaQuery.of(context).size.width - 10,
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
              InternationalPhoneNumberInput(
                onInputChanged: (value) {
                  phoneNumber = value.toString();
                  print(phoneNumber);
                },
                spaceBetweenSelectorAndTextField: 0,
                cursorColor: offersColor,
                inputDecoration: InputDecoration(
                  focusColor: offersColor,
                  hoverColor: offersColor,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: offersColor),
                  ),
                ),
              ),
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
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({'phoneNumber': phoneNumber});

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

  Dialog updated(context, updatedLabel) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        height: 250,
        width: 250,
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: offersColor,
              size: 25,
            ),
            Wrap(
              children: [
                Text(
                  "Your $updatedLabel has been successfully updated",
                  style: TextStyle(color: offersColor, fontSize: 18),
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(color: Colors.green, fontSize: 18.0),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Dialog securityQuestionDialog(
    context,
    widget,
    TextEditingController skill1,
    String label,
    String hintText,
    bool IsLoading,
  ) {
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
                hintText: hintText,
                textInputType: TextInputType.visiblePassword,
              ),
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
                      onPressed: () {
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

  phonenumber() {}
}
