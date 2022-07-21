import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/mainPages/addOfferMain/reviewAndSubmit.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

import '../../main_page.dart';

class imageAndConfigureScreen extends StatefulWidget {
  const imageAndConfigureScreen({Key? key}) : super(key: key);

  @override
  State<imageAndConfigureScreen> createState() =>
      _imageAndConfigureScreenState();
}

class _imageAndConfigureScreenState extends State<imageAndConfigureScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Uint8List? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            DetailsInformation(
                "Choosing the right photo will reflex your Offer cover book. Also, please make sure that the image you are selecting is well showing what you offer"),
            Container(
              height: 15,
            ),
            Center(
              child: Text(
                "Please choose your Offer image",
                style: TextStyle(fontSize: 18),
              ),
            ),
            Container(
              height: 10,
            ),
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: _image != null
                  ? Container(
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                          child: Image(
                        alignment: Alignment.center,
                        image: MemoryImage(_image!),
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      )),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.add_a_photo,
                        color: Colors.black54,
                        size: 35,
                      ),
                      onPressed: () {
                        selectFile();
                        setState(() {
                          reviewAndSubmit.newImage.value = _image!;
                        });
                      },
                    ),
            ),
            Container(
              height: 20,
            ),
            Container(
              height: 50,
              width: 220,
              child: ElevatedButton(
                onPressed: () {
                  selectFile();
                  setState(() {
                    reviewAndSubmit.newImage.value = _image!;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_sharp,
                      size: 30,
                    ),
                    Text('Upload Image')
                  ],
                ),
                style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(), primary: offersColor),
              ),
            ),
          ],
        ),
      )),
    );
  }

  CancelIcon() {
    return IconButton(
        onPressed: () {
          setState(() {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(""),
                  content: Text("Are you sure you want to leave?"),
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    mainPage(isFromSettings: false)),
                          );
                        },
                        child: Text(
                          "Ok",
                          style: TextStyle(color: offersColor),
                        )),
                  ],
                );
                ;
              },
            );
          });
        },
        icon: Icon(
          Icons.close,
          color: Colors.black,
        ));
  }

  void selectFile() async {
    Uint8List Photo = await selectImage(ImageSource.gallery);
    setState(() {
      _image = Photo;
      reviewAndSubmit.newImage.value = _image!;
    });
  }
}
