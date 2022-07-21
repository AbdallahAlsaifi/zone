import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/paymentProcess/pzcoin.dart';
import 'package:zone/screens/auth/fire_auth.dart';
import 'package:zone/screens/auth/login1.dart';
import 'package:zone/screens/auth/signup.dart';
import 'package:zone/screens/mainPages/InDashBoard/chats/chatProvider.dart';
import 'package:zone/screens/mainPages/addOfferMain/addOfferScreen.dart';
import 'package:zone/screens/mainPages/addProjectScreen.dart';
import 'package:zone/screens/mainPages/InDashBoard/dashboard.dart';
import 'package:zone/screens/mainPages/OffersScreen.dart';
import 'package:zone/screens/mainPages/homeScreen/homeScreen.dart';
import 'package:zone/screens/mainPages/leaderboard/leaderboard.dart';
import 'package:zone/screens/mainPages/postScreen.dart';
import 'package:zone/screens/mainPages/profileScreen.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

class mainPage extends StatefulWidget {
  final isFromSettings;

  const mainPage({Key? key, required this.isFromSettings}) : super(key: key);

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getData();
    registerNotification();
    configureLocalNotification();
  }

  int currentTab = 0;
  String uid = " ";
  double userBalance = 0.0;
  var CurrentUserData = {};

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  getData() async {
    try {
      var snap2 = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      CurrentUserData = snap2.data()!;

      setState(() {
        uid = CurrentUserData['uid'];
        userBalance = double.parse(CurrentUserData['balance']);
      });
    } catch (e) {}
  }

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = dashboard();

  bool _isLoading = false;

  void registerNotification() {
    firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(message.notification!);
      }
      return;
    });
    firebaseMessaging.getToken().then((token) {
      if (token != null) {
        updateDataFirestore('users', FirebaseAuth.instance.currentUser!.uid,
            {'pushToken': token});
      }
    }).catchError((error) {
      Fluttertoast.showToast(msg: error.toString());
    });
  }

  void configureLocalNotification() {
    AndroidInitializationSettings initializationAndroidSettings =
        AndroidInitializationSettings("a512");
    IOSInitializationSettings initializationIosSettings =
        IOSInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationAndroidSettings, iOS: initializationIosSettings);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('com.zone.appers.zone', "The Zone",
            playSound: true,
            enableLights: true,
            enableVibration: true,
            importance: Importance.max,
            priority: Priority.high);

    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin.show(0, remoteNotification.title,
        remoteNotification.body, notificationDetails,
        payload: null);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      homeScreen(),
      dashboard(),
      leaderBoard(),
      postScreen(),
      personalOffersScreen(),
      profileScreen(
        uid: FirebaseAuth.instance.currentUser!.uid,
        isVisiting: false,
      )
    ];
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          leading: FittedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.exit_to_app,
                    color: primaryColor,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(""),
                          content: Text("Are you sure you want to logout?"),
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
                                onPressed: () async {
                                  await FireAuth().signOut();
                                  navigateToWithoutBack(context, login1());
                                },
                                child: Text(
                                  "Ok",
                                  style: TextStyle(color: Colors.red),
                                )),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          elevation: 0,
          backgroundColor: offersColor,
          centerTitle: true,
          title: SvgPicture.asset(
            'assets/images/zoneLogo.svg',
            color: primaryColor,
            width: 180,
          ),
          actions: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      navigateTo(context, const pzcoin());
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: 45,
                      width: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          color: primaryColor),
                      child: FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                                child: Icon(
                              Icons.monetization_on,
                              color: offersColor,
                              size: 30,
                            )),
                            FittedBox(
                                child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .snapshots(),
                              builder: (BuildContext content,
                                  AsyncSnapshot snapshot) {
                                return Text(
                                  "  ${snapshot.data!['balance']} ",
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: offersColor,
                                      fontSize: 30.0),
                                );
                              },
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
          bottom: TabBar(
            indicatorColor: offersColor,
            indicatorWeight: 0.0001,
            tabs: [
              Tab(
                text: 'Home',
                icon: Icon(Icons.home),
              ),
              Tab(
                text: 'Dash',
                icon: Icon(Icons.dashboard),
              ),
              Tab(
                text: 'Leader',
                icon: Icon(Icons.flag),
              ),
              Tab(
                text: 'Offers',
                icon: Icon(Icons.local_offer),
              ),
              Tab(
                text: 'Profile',
                icon: Icon(Icons.person),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            homeScreen(),
            dashboard(),
            leaderBoard(),
            personalOffersScreen(),
            profileScreen(
                uid: FirebaseAuth.instance.currentUser!.uid, isVisiting: false)
          ],
        ),
        floatingActionButton: Container(
          margin: EdgeInsets.all(8),
          child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              navigateTo(context, addOfferScreen());
            },
            backgroundColor: secColor,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        backgroundColor: primaryColor,
      ),
    );
  }
}
