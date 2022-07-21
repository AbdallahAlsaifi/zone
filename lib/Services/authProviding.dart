import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/Services/FireStoreSettings.dart';

enum Status {
  uninisialized,
  authenticated,
  authenticating,
  authenticationError,
  authenticationCanceled
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  Status _status = Status.uninisialized;

  Status get status => _status;

  AuthProvider({
    required this.firebaseFirestore,
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
  });

  String? getUserFirebaseId() {
    return prefs.getString("uid");
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn && prefs.getString('uid')?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> handleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection('users')
            .where('uid', isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> document = result.docs;
        if (document.length == 0) {
          String RandomStr = random(1000, 9999).toString();
          firebaseFirestore.collection('users').doc(firebaseUser.uid).set({
            "fname": firebaseUser.displayName,
            "profilePhotoUrl": firebaseUser.photoURL,
            "uid": firebaseUser.uid,
            "dateCreated": DateTime.now().toString(),
            "RegisteredWith": "Google",
            "balance": "0",
            "bio": " ",
            "boughtOffers": "0",
            "lname": "",
            "password": "",
            "phoneNumber": "",
            "rank": "Zoner",
            "rating": "0",
            "ratingCounter": "0",
            "skills": [],
            "activeContracts": [],
            "completedContracts": [],
            "soldOffers": 0,
            "username": firebaseUser.displayName!.toLowerCase() +
                RandomStr.replaceAll(" ", ""),
            "email": googleSignIn.currentUser!.email.toString(),
            "favoriteOffers": [],
            "totalRating": '0',
          });

          User? currentUser = firebaseUser;
          await prefs.setString('uid', currentUser.uid);
          await prefs.setString('fname', currentUser.displayName ?? "");
          await prefs.setString('profilePhotoUrl', currentUser.photoURL ?? "");
          await prefs.setString('RegisteredWith', "Google");
          await prefs.setString(
              'dateCreated', DateTime.now().millisecondsSinceEpoch.toString());
        } else {
          DocumentSnapshot documentSnapshot = document[0];
          User? currentUser = firebaseUser;
          await prefs.setString('uid', currentUser.uid);
          await prefs.setString('fname', currentUser.displayName ?? "");
          await prefs.setString('profilePhotoUrl', currentUser.photoURL ?? "");
          await prefs.setString('RegisteredWith', "Google");
          await prefs.setString(
              'dateCreated', DateTime.now().millisecondsSinceEpoch.toString());
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticationError;
        notifyListeners();
        return false;
      }
    } else {
      _status = Status.authenticationCanceled;
      notifyListeners();
      return false;
    }
  }

  Future<void> handleSignOut() async {
    _status = Status.authenticating;

    await googleSignIn.signOut();
    await googleSignIn.disconnect();
    await firebaseAuth.signOut();
    await prefs.clear();
    _status = Status.uninisialized;
    notifyListeners();
  }

  int random(min, max) {
    return min + Random().nextInt(max - min);
  }
}
