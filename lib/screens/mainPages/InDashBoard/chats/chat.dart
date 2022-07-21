import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zone/Services/UModel.dart' as model;
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/mainPages/InDashBoard/chats/chatScreen.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

import 'chatMsg.dart';

class mainChatsScreen extends StatefulWidget {
  const mainChatsScreen({Key? key}) : super(key: key);

  @override
  State<mainChatsScreen> createState() => _mainChatsScreenState();
}

class _mainChatsScreenState extends State<mainChatsScreen> {
  Stream? chatRoomStream;
  var myData = {};
  var sellerData = {};
  List activeContacts = [];
  List firstNames = [];
  List surnames = [];
  List profilePictures = [];
  List uids = [];

  getData() async {
    try {
      print(activeContacts);
    } catch (e) {}
  }

  getData2() async {
    var snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    myData = await snap.data()!;
    setState(() {
      activeContacts = myData['activeContracts'];
    });
    for (int i = 0; i < activeContacts.length; i++) {
      var ss = {};
      var ss2 = {};
      var snap4 = await FirebaseFirestore.instance
          .collection('Contracts')
          .doc(activeContacts[i])
          .get();
      ss = snap4.data()!;
      String otherId = " ";
      if (ss['sellerId'] == FirebaseAuth.instance.currentUser!.uid) {
        otherId = ss['buyerId'];
      } else {
        otherId = ss['sellerId'];
      }
      var snap2 = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherId)
          .get();
      ss2 = snap2.data()!;

      setState(() {});
      firstNames.add(ss2['fname']);
      surnames.add(ss2['lname']);
      uids.add(ss2['uid']);
      profilePictures.add(ss2['profilePhotoUrl']);

      print(firstNames);
      print(surnames);
      print(uids);
      print(profilePictures);
    }
  }

// void initState(){
//   super.initState();
//   getData(uid);
// }
// var contactData = {};
//   getData(uid) async {
//     try {
//       var snap = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .get();
//
//       contactData = snap.data()!;
//
//       setState(() {});
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getData2();
  }

  @override
  Widget build(BuildContext context) {
    List contracts = [];

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: offersColor,
        title: Text(
          "Chats",
          style: TextStyle(color: primaryColor),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: Text("Loading"));
                }
                var userDocument = snapshot.data;
                List x = userDocument!['activeContracts'];

                return activeContacts.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.4),
                        child: Center(
                          child: Flexible(
                              child: Text(
                            "You don't have any open chats at the moment",
                            style: TextStyle(color: Colors.grey),
                          )),
                        ),
                      )
                    : Wrap(
                        children: chatList(),
                      );
              }),
        ],
      ),
    );
  }

  chatList() {
    List<Widget> x = [];
    for (int index = 0; index < profilePictures.length; index++) {
      x.add(GestureDetector(
          onTap: () {
            navigateTo(
                context,
                chatScreen(
                    contractId: activeContacts[index],
                    isNewContract: false,
                    peerAvatar: profilePictures[index],
                    peerId: uids[index],
                    peerName: firstNames[index] + " " + surnames[index],
                    userAvatar: myData['profilePhotoUrl']));
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(profilePictures[index]),
                      backgroundColor: primaryColor,
                      radius: MediaQuery.of(context).size.width * 0.1,
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        children: [
                          Text(
                            '${firstNames[index]} ${surnames[index]}',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.05),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Icon(
                      Icons.send,
                      color: offersColor,
                      size: MediaQuery.of(context).size.width * 0.1,
                    ),
                  ],
                ),
              ],
            ),
          )));
    }
    return x;
  }
}
