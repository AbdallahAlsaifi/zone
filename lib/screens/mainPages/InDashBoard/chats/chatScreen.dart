import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zone/Services/authProviding.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/paymentProcess/reviewAndRelease/ReviewAndRelease.dart';
import 'package:zone/screens/auth/login1.dart';
import 'package:zone/screens/mainPages/InDashBoard/chats/chatMsg.dart';
import 'package:zone/screens/mainPages/InDashBoard/chats/chatProvider.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

class chatScreen extends StatefulWidget {
  final peerId;

  final peerAvatar;

  final peerName;

  final userAvatar;
  final bool isNewContract;
  final contractId;

  const chatScreen({
    Key? key,
    required this.peerAvatar,
    required this.peerId,
    required this.peerName,
    required this.userAvatar,
    required this.isNewContract,
    required this.contractId,
  }) : super(key: key);

  @override
  State createState() => chatScreenState(
        peerId: peerId,
        peerAvatar: peerAvatar,
        peerName: peerName,
      );
}

class chatScreenState extends State<chatScreen> {
  String userId = "";
  var userData = {};
  var contractData = {};
  var offerData = {};

  chatScreenState(
      {Key? key,
      required this.peerAvatar,
      required this.peerId,
      required this.peerName});

  String peerId, peerAvatar, peerName;
  late String currentUserId;

  List<QueryDocumentSnapshot> listMsgs = new List.from([]);

  int _limit = 20;
  int _limitIncrement = 20;
  File? imageFile;
  File? unkownFile;
  bool isLoading = false;
  String imageUrl = "";
  String unkownUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatProvider chatProvider;
  late AuthProvider authProvider;
  bool isSeller = false;
  bool moneyRequested = false;

  getData() async {
    try {
      var snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      var snap2 = await FirebaseFirestore.instance
          .collection('Contracts')
          .doc(widget.contractId)
          .get();
      userData = snap.data()!;
      contractData = snap2.data()!;
      var snap3 = await FirebaseFirestore.instance
          .collection('Category')
          .doc(contractData['offerId'])
          .get();

      offerData = snap3.data()!;
      if (offerData['uid'] == FirebaseAuth.instance.currentUser!.uid) {
        setState(() {
          isSeller = true;
        });
      }
      userId = userData['uid'];
      currentUserId = userData['uid'];
      setState(() {});
    } catch (e) {}
  }

  void initState() {
    super.initState();
    getData();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProvider>();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMsgs[index - 1].get("senderId") == currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMsgs[index - 1].get("recieverId") != currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(widget.contractId, content,
          FirebaseAuth.instance.currentUser!.uid.toString(), peerId, type);
      listScrollController.animateTo(0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: "Nothing to send",
          backgroundColor: Colors.grey,
          textColor: Colors.white);
    }
  }

  Future uploadFile() async {
    String filename = DateTime.now().toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFile!, filename);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {});
    }
  }

  // void readLocal() async {
  //   if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
  //     currentUserId = authProvider.getUserFirebaseId()!;
  //   } else {
  //     Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (context) => login1()),
  //         (Route<dynamic> route) => false);
  //   }
  //   if (currentUserId.hashCode <= peerId.hashCode) {
  //     groupChatId = '$currentUserId';
  //   } else {
  //     groupChatId = '$currentUserId';
  //   }
  //
  //   chatProvider.updateDataFirestore('users', 'uid', {'recevierId': peerId});
  // }

  Future<bool> onBackPress() {
    chatProvider.updateDataFirestore(
      'users',
      currentUserId,
      {'recieverId': peerId},
    );
    Navigator.pop(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          centerTitle: true,
          title: FittedBox(
            child: Text(
              this.peerName,
              style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontSize: 30.0),
            ),
          ),
          backgroundColor: offersColor,
          elevation: 0,
          actions: [
            isSeller
                ? FittedBox(
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(""),
                              content: Text(
                                "Are you sure you want to Request the Money?\n\nPlease contact\nsupport@appers.org\n\n**Only if the client refused to release the money",
                              ),
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
                      },
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(90)),
                        child: Center(
                          child: Row(
                            children: [
                              Text(
                                'Request Money',
                                style: TextStyle(
                                    color: offersColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                Icons.monetization_on_outlined,
                                color: offersColor,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : FittedBox(
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(""),
                              content: Text(
                                  "Are you sure you want to Release Money?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      navigatePop(context, widget);
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: offersColor),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      //here
                                      navigatePop(context, widget);
                                      navigateTo(
                                          context,
                                          ReviewAndRelease(
                                            contractId: widget.contractId,
                                          ));
                                    },
                                    child: Text(
                                      "Ok",
                                      style: TextStyle(color: offersColor),
                                    )),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(90)),
                        child: Center(
                          child: Row(
                            children: [
                              Text(
                                'Release Money',
                                style: TextStyle(
                                    color: offersColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                Icons.monetization_on_outlined,
                                color: offersColor,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(8),
          child: WillPopScope(
            onWillPop: onBackPress,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildListMessage(),
                    Input(),
                  ],
                ),
                buildLoading(),
              ],
            ),
          ),
        ));
  }

  Widget Input() {
    return Container(
      child: Row(children: [
        Material(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 1),
            child: IconButton(
              icon: Icon(
                Icons.image,
                color: offersColor,
              ),
              onPressed: getImage,
              color: offersColor,
            ),
          ),
          color: Colors.white,
        ),
        Material(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 1),
            child: IconButton(
              icon: Icon(
                Icons.file_open,
                color: offersColor,
              ),
              onPressed: getImage,
              color: offersColor,
            ),
          ),
          color: Colors.white,
        ),
        Flexible(
            child: Container(
          child: TextField(
            onSubmitted: (value) {
              onSendMessage(textEditingController.text, TypeMessage.TEXT);
            },
            style: TextStyle(color: Colors.grey, fontSize: 15.0),
            controller: textEditingController,
            decoration: InputDecoration.collapsed(
              hintText: 'Type a message...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            focusNode: focusNode,
          ),
        )),
        Material(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 1),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: offersColor,
              ),
              onPressed: () =>
                  onSendMessage(textEditingController.text, TypeMessage.TEXT),
              color: offersColor,
            ),
          ),
          color: Colors.white,
        ),
      ]),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      ChatMsg chatMsg = ChatMsg.fromDocument(document);
      if (chatMsg.senderId == currentUserId) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            chatMsg.type == TypeMessage.TEXT
                ? Container(
                    child: Text(chatMsg.content,
                        style: TextStyle(
                            color: offersColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600)),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8.0)),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                        right: 10.0),
                  )
                : chatMsg.content == TypeMessage.IMAGE
                    ? Container(
                        child: OutlinedButton(
                          child: Material(
                            child: Image.network(
                              chatMsg.content,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    image: DecorationImage(
                                      image: NetworkImage(chatMsg.content),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: offersColor,
                                      value:
                                          progress.expectedTotalBytes != null &&
                                progress.expectedTotalBytes !=
                                    null
                                ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, object, stacktrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        width: 200,
                        height: 200,
                        child: Center(
                          child: Text('Error: $object'),
                        ),
                      );
                    },
                  ),
                ),
                onPressed: () {
                  //TODO:image full view
                          },
              ),
              margin: EdgeInsets.only(
                  bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                  right: 10.0),
            )
                : Container(
                        width: 200,
                        height: 200,
                        child: Image.network(
                          chatMsg.content,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20 : 10,
                            right: 10),
                      )
          ],
        );
      } else {
        return Container(
          child: Column(
            children: [
              Row(
                children: [
                  isLastMessageLeft(index)
                      ? Material(
                          child: Image.network(
                            peerAvatar,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: offersColor,
                                  value: progress.expectedTotalBytes != null &&
                                          progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                size: 35,
                                color: Colors.grey,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          clipBehavior: Clip.hardEdge,
                        )
                      : Container(
                          width: 35,
                        ),
                  chatMsg.type == TypeMessage.TEXT
                      ? Container(
                          child: Text(chatMsg.content,
                              style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600)),
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          width: 200.0,
                          decoration: BoxDecoration(
                              color: offersColor,
                              borderRadius: BorderRadius.circular(8.0)),
                          margin: EdgeInsets.only(
                              bottom: isLastMessageLeft(index) ? 20.0 : 10.0,
                              right: 10.0,
                              left: 10.0),
                        )
                      : chatMsg.type == TypeMessage.IMAGE
                          ? Container(
                              child: TextButton(
                                child: Material(
                                  child: Image.network(
                                    chatMsg.content,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          image: DecorationImage(
                                            image:
                                                NetworkImage(chatMsg.content),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: offersColor,
                                            value: progress.expectedTotalBytes !=
                                                        null &&
                                                    progress.expectedTotalBytes !=
                                                        null
                                                ? progress
                                                        .cumulativeBytesLoaded /
                                                    progress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, object, stacktrace) =>
                                            Material(
                                      child: Container(
                                        color: Colors.grey.shade300,
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: Text('Error: $object'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  //image full view
                                },
                              ),
                              margin: EdgeInsets.only(
                                  bottom:
                                      isLastMessageRight(index) ? 20.0 : 10.0,
                                  right: 10.0),
                            )
                          : Container(
                              child: Image.network(
                                chatMsg.content,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              margin: EdgeInsets.only(
                                  bottom: isLastMessageRight(index) ? 20 : 10,
                                  right: 10),
                            )
                ],
              ),
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        chatMsg.timeSent.split(".")[0].split(':')[0] +
                            ":" +
                            chatMsg.timeSent.split(".")[0].split(':')[1],
                        style: TextStyle(color: Colors.grey.shade300),
                      ),
                    )
                  : SizedBox.shrink()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildListMessage() {
    return Flexible(
        child: widget.contractId.isNotEmpty
            ? StreamBuilder<QuerySnapshot>(
                stream: chatProvider.getChatStream(widget.contractId, _limit),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    listMsgs = snapshot.data!.docs;
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItem(index, snapshot.data!.docs[index]),
                      itemCount: snapshot.data!.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return Center(
                        child: CircularProgressIndicator(
                      color: offersColor,
                    ));
                  }
                })
            : Center(
                child: CircularProgressIndicator(
                color: offersColor,
              )));
  }

  Widget buildLoading() {
    return Positioned(
        child: isLoading
            ? CircularProgressIndicator(
                color: offersColor,
              )
            : SizedBox.shrink());
  }
}
