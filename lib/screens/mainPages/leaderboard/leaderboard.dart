import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/mainPages/profileScreen.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

class leaderBoard extends StatefulWidget {
  const leaderBoard({Key? key}) : super(key: key);

  @override
  State<leaderBoard> createState() => _leaderBoardState();
}

class _leaderBoardState extends State<leaderBoard> {
  @override
  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    CollectionReference recipes =
        FirebaseFirestore.instance.collection('users');
    return Scaffold(
      backgroundColor: primaryColor,
      body: StreamBuilder<QuerySnapshot>(
          stream: recipes
              .orderBy('soldOffers', descending: true)
              .limit(100)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return ListView.builder(
              controller: ScrollController(),
              reverse: false,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: topThree(index)),
                  child: ListTile(
                    leading: FittedBox(
                      child: Row(
                        children: [
                          Text(
                            '#${index + 1}  ',
                            style: TextStyle(
                                fontSize: 20, color: topThreeButton(index)),
                          ),
                          CircleAvatar(
                            backgroundColor: primaryColor,
                            backgroundImage: NetworkImage(
                                snapshot.data!.docs[index]['profilePhotoUrl']),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      '${snapshot.data!.docs[index]['fname']} ${snapshot.data!.docs[index]['lname']}',
                      overflow: TextOverflow.fade,
                    ),
                    subtitle: Column(
                      children: [
                        Text(
                            'Sold offers: ${snapshot.data!.docs[index]['soldOffers']}'),
                        Row(
                          children: [
                            Text(
                              'Rating: ${snapshot.data!.docs[index]['rating']}',
                              style: TextStyle(fontSize: 10),
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            )
                          ],
                        )
                      ],
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        navigateTo(
                            context,
                            profileScreen(
                              uid: snapshot.data!.docs[index]['uid'],
                              isVisiting: true,
                            ));
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Visit Profile',
                              style: TextStyle(color: primaryColor),
                            ),
                            Icon(
                              Icons.account_box_outlined,
                              color: primaryColor,
                            )
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: topThreeButton(index),
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  topThree(x) {
    if (x + 1 == 1) {
      return Border.all(color: Colors.amber, width: 4);
    } else if (x + 1 == 2) {
      return Border.all(color: Colors.teal, width: 3);
    } else if (x + 1 == 3) {
      return Border.all(color: Colors.blueGrey, width: 2);
    } else {
      return Border.all(color: offersColor, width: 1);
    }
  }

  topThreeButton(x) {
    if (x + 1 == 1) {
      return Colors.amber;
    } else if (x + 1 == 2) {
      return Colors.teal;
    } else if (x + 1 == 3) {
      return Colors.blueGrey;
    } else {
      return offersColor;
    }
  }
}
