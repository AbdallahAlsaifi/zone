import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/Appers/appersHome.dart';
import 'package:zone/Services/authProviding.dart';
import 'package:zone/Services/changeScreenProvider.dart';
import 'package:zone/Services/sharedPrefs.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/appersMain.dart';
import 'package:zone/paymentProcess/PurchaseApi.dart';
import 'package:zone/screens/auth/login.dart';
import 'package:zone/screens/auth/listner.dart';
import 'package:zone/screens/auth/login1.dart';
import 'package:zone/screens/mainPages/InDashBoard/chats/chatProvider.dart';
import 'package:zone/screens/mainPages/InDashBoard/dashboard.dart';
import 'package:zone/screens/main_page.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:zone/screens/auth/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Stripe.publishableKey =
      'pk_test_51LCR7AKoEwOhE0oQLG2AhlpFcEnBEYcyThz37eoiaOP5C2lnwCS9Fm6OjuhhFZ768LSosBR6AWWaKlqSnmSUOZog00weaG3mso';
  await Stripe.instance.applySettings();

  await sharedprefs.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    ErrorWidget.builder = (FlutterErrorDetails details) => Scaffold(
          backgroundColor: primaryColor,
          body: Center(
              child: Container(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ))),
        );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    runApp(new MyApp(prefs: prefs));
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({Key? key, required this.prefs}) : super(key: key);

  static const String _title = 'Welcome To The Zone';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChangeScreenProvider()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            prefs: this.prefs,
            firebaseFirestore: this.firebaseFirestore,
            googleSignIn: GoogleSignIn(),
          ),
        ),
        Provider<ChatProvider>(
          create: (_) => ChatProvider(
              prefs: this.prefs,
              firebaseFirestore: this.firebaseFirestore,
              firebaseStorage: this.firebaseStorage),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: _title,
        home: MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return const mainPage(
                isFromSettings: false,
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            }
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }
          return login1();
        });
  }
}
