import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:zone/Services/authProviding.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/auth/fire_auth.dart';
import 'package:zone/screens/auth/resitPassword.dart';
import 'package:zone/screens/auth/signup.dart';
import 'package:zone/screens/auth/signup1.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';
import 'package:zone/widgets/widgets.dart';
import 'package:zone/components/components.dart';
import '../main_page.dart';
import 'package:zone/screens/auth/signup.dart';

class login1 extends StatefulWidget {
  const login1({Key? key}) : super(key: key);

  @override
  State<login1> createState() => _login1State();
}

class _login1State extends State<login1> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  bool _isLoading = false;
  String EmailField = "";
  String PasswordField = "";

  void signInUser() async {
    try {
      setState(() {
        _isLoading = true;
      });

      String result = await FireAuth().signInUser(context,
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

      if (result == 'success') {
        navigateToWithoutBack(
            context,
            mainPage(
              isFromSettings: false,
            ));
        Fluttertoast.showToast(msg: "Logged In successfully");
      } else {
        Fluttertoast.showToast(msg: "Error Login\nPlease check your entry");
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authenticationError:
        Fluttertoast.showToast(msg: "Sign In Fail");
        break;
      case Status.authenticationCanceled:
        Fluttertoast.showToast(msg: "Sign In Cancelled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign In Success");
        break;
      default:
        break;
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  const Upside(
                    imgUrl: "assets/images/login.png",
                  ),
                  const PageTitleBar(title: 'Login to your account'),
                  Padding(
                    padding: const EdgeInsets.only(top: 320.0),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          GestureDetector(
                              onTap: () async {
                                try {
                                  bool isSuccess =
                                      await authProvider.handleSignIn();
                                  if (isSuccess == true) {
                                    navigateTo(context,
                                        mainPage(isFromSettings: false));
                                    print('Success');
                                  } else {
                                    Fluttertoast.showToast(msg: "Didn't work");
                                    print('Failed');
                                  }
                                } catch (e) {
                                  Fluttertoast.showToast(msg: e.toString());
                                }
                              },
                              child: iconButton(context)),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "or use your email account",
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'OpenSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          Form(
                            child: Column(
                              children: [
                                RoundedInputField(
                                    x: EmailField,
                                    hintText: "Email",
                                    icon: Icons.email,
                                    controller: _emailController),
                                RoundedPasswordField(
                                  x: PasswordField,
                                  passwordController: _passwordController,
                                ),
                                switchListTile(),
                                RoundedButton(
                                    isLoading: _isLoading,
                                    text: 'LOGIN',
                                    press: () {
                                      // signInUser();
                                      try {
                                        signInUser();
                                      } catch (e) {
                                        navigateTo(context, login1());
                                      }
                                      print("###########################");
                                      print(_emailController.text);
                                      print(_passwordController.text);
                                      print("###########################");
                                    }),
                                const SizedBox(
                                  height: 10,
                                ),
                                UnderPart(
                                  title: "Don't have an account?",
                                  navigatorText: "Register here",
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignUp1()));
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      navigateTo(context, resitPassword()),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                        color: offersColor,
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  switchListTile() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 40),
      child: SwitchListTile(
        dense: true,
        title: const Text(
          'Remember Me',
          style: TextStyle(fontSize: 16, fontFamily: 'OpenSans'),
        ),
        value: true,
        activeColor: offersColor,
        onChanged: (val) {},
      ),
    );
  }

  iconButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        RoundedIcon(imageUrl: "assets/images/google.jpg"),
      ],
    );
  }
}