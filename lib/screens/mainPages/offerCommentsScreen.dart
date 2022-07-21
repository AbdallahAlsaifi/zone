import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zone/additional/colors.dart';
import 'package:zone/screens/mainPages/profileScreen.dart';
import 'package:zone/widgets/AdditionalWidgets.dart';

class offerComments extends StatefulWidget {
  final offerId;

  const offerComments({Key? key, required this.offerId}) : super(key: key);

  @override
  State<offerComments> createState() => _offerCommentsState();
}

class _offerCommentsState extends State<offerComments> {
  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    CollectionReference recipes = FirebaseFirestore.instance
        .collection('Category')
        .doc(widget.offerId)
        .collection('comments');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: offersColor,
        title: Text(
          'Offer Rating',
          style: TextStyle(color: primaryColor),
        ),
        centerTitle: true,
      ),
      backgroundColor: primaryColor,
      body: StreamBuilder<QuerySnapshot>(
          stream: recipes.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              controller: ScrollController(),
              reverse: false,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: offersColor)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor,
                      backgroundImage: NetworkImage(
                          snapshot.data!.docs[index]['profilePhotoUrl']),
                    ),
                    title: Text(
                      '${snapshot.data!.docs[index]['fname']} ${snapshot.data!.docs[index]['lname'] ?? " "}',
                      overflow: TextOverflow.fade,
                    ),
                    subtitle: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '${snapshot.data!.docs[index]['rate']}',
                              style: TextStyle(fontSize: 15),
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            )
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            children: [
                              Text('Comment: '),
                              Divider(),
                              Wrap(
                                children: [
                                  Text(
                                      '${snapshot.data!.docs[index]['comment']}')
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        navigateTo(
                            context,
                            profileScreen(
                              uid: snapshot.data!.docs[index]['ratedBy'],
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
                            color: offersColor,
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
}
