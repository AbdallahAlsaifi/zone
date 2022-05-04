import 'package:flutter/material.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/auth/login.dart';
import 'package:zone/screens/settingsScreens/aboutUsScreen.dart';
import 'package:zone/screens/settingsScreens/helpScreen.dart';
import 'package:zone/screens/settingsScreens/personalSettingsScreen.dart';
import 'package:zone/screens/settingsScreens/portfolioScreen.dart';
import 'package:zone/screens/settingsScreens/profileSettingsScreen.dart';
import 'package:zone/screens/settingsScreens/securityScreens.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

import '../auth/fire_auth.dart';

class userSettings extends StatefulWidget {
  const userSettings({Key? key}) : super(key: key);

  @override
  State<userSettings> createState() => _userSettingsState();
}

class _userSettingsState extends State<userSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: primaryColor,
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: primaryColor),
        ),
        elevation: 0,
        backgroundColor: secColor,
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: EdgeInsets.only(top: 30),
              padding: EdgeInsets.all(12.0),
              child: ListView(
                padding: EdgeInsets.all(5.0),
                children: [
                  settingButton("Profile Settings", Icons.person_pin,context, profileSettingsScreen()),
                  const SizedBox(height: 12,),
                  settingButton("Personal Settings", Icons.person_outline, context, personalSettingsScreen()),
                  const SizedBox(height: 12,),
                  settingButton("Security", Icons.shield_outlined, context, securityScreens()),
                  const SizedBox(height: 12,),
                  settingButton("Portfolio", Icons.photo_album_outlined, context,portfolioScreen()),
                  const SizedBox(height: 12,),
                  settingButton("Help", Icons.help_outline, context,helpScreen()),
                  const SizedBox(height: 12,),
                  settingButton("About Us", Icons.emoji_people_rounded, context,aboutUsScreen()),
                  const SizedBox(height: 12,),
                  //logout button
                  InkWell(
                    onTap: () async {
                      await FireAuth().signOut();
                      navigateToWithoutBack(context, login());
                    },
                    child: Container(
                        child: Text(
                          'Log out',
                          style: (TextStyle(color: primaryColor)),
                        ),
                        alignment: Alignment.center,
                        width: 150,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4))),
                          color: secColor,
                        )),
                  ),
                ],
              )
            )),
      ),
    );
  }
}