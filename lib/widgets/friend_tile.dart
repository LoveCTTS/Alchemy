import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/chat_page.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FriendTile extends StatelessWidget {

  final String friendName;
  FirebaseUser _user;

  FriendTile({this.friendName});

  final kInnerDecoration = BoxDecoration(
    color: Color(0xfffffafa),
    border: Border.all(color: Colors.white),
    borderRadius: BorderRadius.circular(32),
  );

  final kGradientBoxDecoration = BoxDecoration(
    gradient: LinearGradient(colors: [Color(0xff000080),Color(0xff4b0082)]),
    border: Border.all(
      color: Colors.white,
    ),
    borderRadius: BorderRadius.circular(32),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 200, height: 50.0, decoration: kGradientBoxDecoration,
            padding: EdgeInsets.all(0.5), //Gradient Border size 조절
            child: GestureDetector(
              onTap: () async {

              },
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text("$friendName", style:TextStyle(fontWeight: FontWeight.bold,fontSize:20,color: Color(0xff483d8b),
                            fontFamily: "RobotoMono-italic"))),
                    decoration: kInnerDecoration
                ),
              ),

            ),
          ),SizedBox(height:10)]
    );
  }
}
