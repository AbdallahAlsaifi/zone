import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/auth/login.dart';
import 'package:zone/screens/auth/login1.dart';
import 'package:zone/screens/mainPages/InDashBoard/support.dart';
import 'package:zone/screens/mainPages/profileScreen.dart';
import 'package:zone/screens/main_page.dart';
import 'package:zone/screens/settingsScreens/aboutUsScreen.dart';
import 'package:zone/screens/settingsScreens/helpScreen.dart';
import 'package:zone/screens/settingsScreens/personalSettingsScreen.dart';
import 'package:zone/screens/settingsScreens/Portfolio/portfolioScreen.dart';
import 'package:zone/screens/settingsScreens/profileSettingsScreen.dart';
import 'package:zone/screens/settingsScreens/securityScreens.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

import '../auth/fire_auth.dart';

class userSettings extends StatefulWidget {
  final bool isAfterChange;

  const userSettings({Key? key, required this.isAfterChange}) : super(key: key);

  @override
  State<userSettings> createState() => _userSettingsState();
}

class _userSettingsState extends State<userSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAfterChange == true) {
      Future.delayed(
          Duration(milliseconds: 100),
          () => showAlertDialog(
              context,
              "Sucess",
              "Your information has been successfully updated",
              Icon(
                Icons.check_circle,
                color: offersColor,
                size: 50,
              )));
    }
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: primaryColor,
          onPressed: () {
            navigateToWithoutBack(
                context,
                mainPage(
                  isFromSettings: true,
                ));
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: primaryColor),
        ),
        elevation: 0,
        backgroundColor: secColor,
      ),
      body: widget.isAfterChange
          ? Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      margin: EdgeInsets.only(top: 30),
                      padding: EdgeInsets.all(12.0),
                      child: ListView(
                        padding: EdgeInsets.all(5.0),
                        children: [
                          settingButton("Profile Settings", Icons.person_pin,
                              context, profileSettingsScreen()),
                          const SizedBox(
                            height: 12,
                          ),
                          settingButton(
                              "Personal Settings",
                              Icons.person_outline,
                              context,
                              personalSettingsScreen()),
                          const SizedBox(
                            height: 12,
                          ),
                          settingButton("Security", Icons.shield_outlined,
                              context, securityScreens()),
                          const SizedBox(
                            height: 12,
                          ),
                          settingButton(
                              "Portfolio",
                              Icons.photo_album_outlined,
                              context,
                              portfolioScreen(
                                isAfterAddingANewPortfolio: false,
                              )),
                          const SizedBox(
                            height: 12,
                          ),
                          settingButton("Help", Icons.help_outline, context,
                              helpScreen()),
                          const SizedBox(
                            height: 12,
                          ),
                          settingButton("About Us", Icons.emoji_people_rounded,
                              context, aboutUsScreen()),
                          const SizedBox(
                            height: 12,
                          ),
                          //logout button
                          InkWell(
                            onTap: () async {
                              await FireAuth().signOut();
                              navigateToWithoutBack(context, login1());
                            },
                            child: Container(
                                child: Text(
                                  'Log out',
                                  style: (TextStyle(color: primaryColor)),
                                ),
                                alignment: Alignment.center,
                                width: 150,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: const ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  color: secColor,
                                )),
                          ),
                        ],
                      ))),
            )
          : Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      margin: EdgeInsets.only(top: 30),
                      padding: EdgeInsets.all(12.0),
                      child: ListView(
                        padding: EdgeInsets.all(5.0),
                        children: [
                          settingButton("Profile Settings", Icons.person_pin,
                              context, profileSettingsScreen()),
                          const SizedBox(
                            height: 12,
                          ),
                          settingButton(
                              "Personal Settings",
                              Icons.person_outline,
                              context,
                              personalSettingsScreen()),
                          const SizedBox(
                            height: 12,
                          ),
                          settingButton("Security", Icons.shield_outlined,
                              context, securityScreens()),
                          const SizedBox(
                            height: 12,
                          ),
                          settingButton(
                              "Portfolio",
                              Icons.photo_album_outlined,
                              context,
                              portfolioScreen(
                                isAfterAddingANewPortfolio: false,
                              )),
                          const SizedBox(
                            height: 12,
                          ),
                          settingButton(
                              "Help", Icons.help_outline, context, support()),
                          const SizedBox(
                            height: 12,
                          ),
                          settingButton("About Us", Icons.emoji_people_rounded,
                              context, aboutUsScreen()),
                          const SizedBox(
                            height: 12,
                          ),
                          //logout button
                          InkWell(
                            onTap: () async {
                              await FireAuth().signOut();
                              navigateToWithoutBack(context, login1());
                            },
                            child: Container(
                                child: Text(
                                  'Log out',
                                  style: (TextStyle(color: primaryColor)),
                                ),
                                alignment: Alignment.center,
                                width: 150,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: const ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  color: secColor,
                                )),
                          ),
                        ],
                      ))),
            ),
    );
  }
}
