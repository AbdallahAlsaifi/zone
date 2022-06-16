import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/additional/colors.dart';

class RoundedButton extends StatelessWidget {
  final isLoading;

  const RoundedButton(
      {Key? key,
      this.press,
      this.textColor = Colors.white,
      required this.text,
      required this.isLoading})
      : super(key: key);
  final text;
  final press;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: newElevatedButton(),
      ),
    );
  }

  Widget newElevatedButton() {
    return ElevatedButton(
      child: isLoading
          ? CircularProgressIndicator(
              color: primaryColor,
            )
          : Text(
              text,
              style: TextStyle(color: textColor, fontSize: 17),
            ),
      onPressed: press,
      style: ElevatedButton.styleFrom(
          primary: offersColor,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          textStyle: TextStyle(
              letterSpacing: 2,
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans')),
    );
  }
}

class RoundedIcon extends StatelessWidget {
  const RoundedIcon({Key? key, required this.imageUrl}) : super(key: key);
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, offset: Offset(0, 2), blurRadius: 0.6),
            ],
            image: DecorationImage(
              image: AssetImage(imageUrl),
            )),
      ),
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  const TextFieldContainer({Key? key, this.child}) : super(key: key);
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(29),
      ),
      child: child,
    );
  }
}

class RoundedInputField extends StatelessWidget {
  final controller;

  RoundedInputField(
      {Key? key,
      this.hintText,
      required this.controller,
      this.icon = Icons.person})
      : super(key: key);
  final String? hintText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        controller: controller,
        cursorColor: offersColor,
        decoration: InputDecoration(
            icon: Icon(
              icon,
              color: offersColor,
            ),
            hintText: hintText,
            hintStyle: const TextStyle(fontFamily: 'OpenSans'),
            border: InputBorder.none),
      ),
    );
  }
}

class RoundedPasswordField extends StatefulWidget {
  final TextEditingController passwordController;

  const RoundedPasswordField({Key? key, required this.passwordController})
      : super(key: key);

  @override
  State<RoundedPasswordField> createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  @override
  bool isObscure = true;

  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        controller: widget.passwordController,
        obscureText: isObscure,
        cursorColor: offersColor,
        decoration: InputDecoration(
            icon: Icon(
              Icons.lock,
              color: offersColor,
            ),
            hintText: "Password",
            hintStyle: TextStyle(fontFamily: 'OpenSans'),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  isObscure = !isObscure;
                });
              },
              child: Icon(
                Icons.visibility,
                color: offersColor,
              ),
            ),
            border: InputBorder.none),
      ),
    );
  }
}